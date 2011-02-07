#!/usr/bin/ruby

require "rubygems"
require "eventmachine"
require "singleton"
require "rubygame"
include Rubygame

require "libs/env"
require "libs/msg"
require "libs/vobject"
require "libs/table"
require "libs/deck"
require "libs/card"
require "libs/hand"
require "libs/menu"

$DELIM = "\r\n"

class Game < EventMachine::Connection
  attr_reader :running
  
  # Costruttore della classe.
  def initialize
    @screen = Screen.new([1024, 768], 
                         0, 
                         [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF])
    @screen.title = "Virtual Table"
    @events = Rubygame::EventQueue.new
    @events.enable_new_style_events    
    # Game data
    @picked = nil # oggetto preso col click e loccato, si assegna il nick
    @menu = nil
    @accepted = false # true quando il server accetta l'entrata in gioco
    @running = true # se false il client esce
  rescue Exception => e
    p e
    exit
  end
  
  def set_nick(nick)
    # Send nick
    @nick = nick != "" ? nick.capitalize : "Guest_#{rand 1000}"
    send_msg(Msg.dump(:type => "Nick", :args => @nick))
  end
  
  # Connessione persa o uscita dal client.
  def unbind
    @running = false
  end
  
  # Procedura che viene richiamata ciclicamente, loop del game.
  def loop
    env = Env.instance
    @events.each do |ev|
      # puts ev.inspect
      case ev
      when Rubygame::Events::MousePressed
        env.objects.reverse.each do |o|
          if o.collide?(*ev.pos)
            if (o.is_pickable? and (o.locker == nil or o.is_locked?(@nick)))
              # richiesta del pick
              send_msg(Msg.dump(:type => "Pick", 
                                :oid => o.oid, 
                                :args => [ev.button, ev.pos]))
            end
            break
          end
        end
      when Rubygame::Events::KeyPressed
        if (@picked and @picked.kind_of?(Card) and ev.key == :left_ctrl)
          env.flag = true # arrivato evento si disegna
          send_msg(Msg.dump(:type => "Action", 
                            :oid => @picked.oid, 
                            :args => :action_turn))
        end
      when Rubygame::Events::MouseReleased
        if @picked
          env.flag = true # arrivato evento si disegna
          if (@menu and @menu.choice)
            # azione sull'oggetto e invio al server
            @picked.send(@menu.choice.to_sym)
            send_msg(Msg.dump(:type => "Action", 
                              :oid => @picked.oid, 
                              :args => @menu.choice.to_sym))
            if @menu.choice.end_with?("card4all")
              # richiesta valore carte attiva
              send_msg(Msg.dump(:type => "GetValue"))
            end
          end
          @menu = nil # chiusura menu
          # rilascio dell'oggetto in pick e quindi lockato
          send_msg(Msg.dump(:type => "UnLock", :oid => @picked.oid))
          @picked = nil
        end
      when Rubygame::Events::MouseMoved
        if @picked
          env.flag = true # arrivato evento si disegna
          if (ev.buttons[0] == :mouse_left and @menu == nil)
            # spostamento se l'oggetto e' in pick
            move = @picked.move(*ev.pos) # muove l'oggetto
            if move
              # se si vuole lo manda al server
              send_msg(Msg.dump(:type => "Move", 
                                :oid => @picked.oid, 
                                :args => move))
            end
          else
            # se e' click destro l'evento passa al menu
            @menu.select(ev) if @menu
          end
        end
      when Rubygame::Events::QuitRequested
        unbind
      else
        # puts ev.inspect
      end
    end
  end
  
  def update
    env = Env.instance
    # disegna se c'e stato un cambiamento (flag) ed e' accettato
    if (@accepted and env.flag)
      env.flag = false # imposta come disegnato
      env.table.draw(@screen)
      env.objects.each { |o| o.draw(@screen) }
      @menu.draw(@screen) if @menu
      @screen.flip
    end
  end
  
  # Invia messaggi al server.
  def send_msg(data)
    data = "#{data}#{$DELIM}" unless data.end_with?($DELIM)
    send_data(data)
  end
  
  # Ricezione e gestione dei messaggi del server.
  def receive_data(data)
    env = Env.instance
    env.flag = true # arrivato messaggio si disegna
    data.split($DELIM).each do |str|
      begin
        m = Msg.load(str)
      rescue
        next
      end
      case m.type
      when "Object"
        if m.data.kind_of?(Table)
          env.add_table(m.data.init_graph)
        elsif m.data.kind_of?(Array)
          m.data.each do |o|
            env.add_object(o.init_graph)
          end
          env.add_hand(env.get_object(@nick))
        end
        @accepted = true # accettato dal server, si iniziare a disegnare
      when "Move"
        env.get_object(m.oid).set_pos(*m.args)
      when "Pick"
        @picked = env.get_object(m.oid)
        @picked.save_pick_pos(*m.args[1]) # salva il punto di click
        if (m.args[0] == :mouse_left)
          unless @picked.kind_of?(Hand)
            # preso l'oggetto in pick, va in primo piano no per hand
            @picked.to_front
          end
        else
          # click destro si crea un menu in base all'oggetto
          @menu = Menu.new(m.args[1], @picked)
        end
      when "Lock"
        o = env.get_object(m.oid)
        o.lock(m.args[1]) # lock, nick di chi ha fatto pick
        # prim piano oggetto in pick, lockato, da un altro client
        o.to_front if (m.args[0] == :mouse_left)
      when "UnLock"
        env.get_object(m.oid).unlock # toglie il lock
      when "Hand"
        env.add_first_object(m.data.init_graph) # hand nuovo giocatore
      when "UnHand"
        env.del_object_by_id(m.oid) # va via un giocatore
      when "Action"
        args = Array(m.args)
        env.get_object(m.oid).send(*args) # azione sull'oggetto
        # richiesta passiva valore carte
        if (args[0].to_s.end_with?("card4all"))
          send_msg(Msg.dump(:type => "GetValue"))
        end
      end
    end
  end
  
end


if __FILE__ == $0
  
  game_exit = proc do
    Rubygame.quit
    EventMachine::stop_event_loop if EventMachine::reactor_running?
    puts
    exit
  end
  
  trap("INT") do
    game_exit.call
  end
  
  puts "\nVirtual Table Client"
  print "Inserisci l'ip del server (0.0.0.0): "
  $IP = $stdin.gets.chomp
  print "Inserisci un nick: "
  $NICK = $stdin.gets.chomp
  
  EventMachine::run do
    emg = EventMachine::connect($IP != "" ? $IP : "0.0.0.0", 3333, Game)
    emg.set_nick($NICK)
    clock = Rubygame::Clock.new
    clock.target_framerate = 30    
    game_loop = proc do 
      emg.loop
      game_exit.call unless emg.running
      emg.update
      clock.tick
      EventMachine.next_tick(game_loop)
    end
    game_loop.call
  end
  
end

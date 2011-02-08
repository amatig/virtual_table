#!/usr/bin/ruby

require "rubygems"
require "eventmachine"
require "singleton"
require "rubygame/rect"

require "libs/env"
require "libs/msg"
require "libs/vobject"
require "libs/table"
require "libs/deck"
require "libs/secret_deck"
require "libs/card"
require "libs/hand"

$DELIM = "\r\n"

# Classe.
# = Description
# Classe.
# = License
# Virtual Table - Tavolo da gioco virtuale
#
# Copyright (C) 2011 Giovanni Amati
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
# = Authors
# Giovanni Amati

class Server
  
  # Costruttore della classe.
  def initialize
    # Game data all'avvio del server
    env = Env.instance
    env.add_table(Table.new) # tavolo
    env.add_object(env.set_deck(DeckPoker.new)) # aggiunge deck
  end
  
  # Avvio della ricezione di connessioni da parte di client.
  def start
    EventMachine.start_server('0.0.0.0', 3333, Connection) do |conn|
      # aggiunge il nuovo client all'hash
      Env.instance.add_client(conn)
    end
  end
  
end

class Connection < EventMachine::Connection
  
  # Init della connessione del client.
  def post_init
    # ...
  rescue Exception => e
    p e
    exit
  end
  
  # Connessione persa o uscita del client.
  def unbind
    env = Env.instance
    # rimuove la hand dal server e da tutti i client
    hand = env.del_hand_by_id(self.object_id)
    resend_without_me(Msg.dump(:type => "UnHand", :oid => hand.oid))
    # unlock di tutti gli oggetti del client
    env.objects.each do |o|
      if o.is_locked?(@nick)
        o.unlock 
        resend_without_me(Msg.dump(:type => "UnLock", :oid => o.oid))
      end
    end
    # rimuove il client dell'hash delle connessioni
    env.del_client(self)
  end
  
  # Ricezione e gestione dei messaggi del client.
  def receive_data(data)
    env = Env.instance
    # puts Thread.current
    data.split($DELIM).each do |str|
      begin
        m = Msg.load(str)
      rescue
        next
      end
      case m.type
      when "Nick"
        @nick = m.args
        # mette in hash e objects la nuova hand
        hand = env.add_hand(self.object_id, Hand.new(@nick))
        # manda a tutti gli altri la hand
        resend_without_me(Msg.dump(:type => "Hand", :data => hand))
        # invio dei dati del gioco tavolo, oggetti
        send_me(Msg.dump(:type => "Object", :data => env.table))
        send_me(Msg.dump(:type => "Object", :data => env.objects))
      when "Pick"
        o = env.get_object(m.oid)
        # vede se un oggetto e' disponibile
        if (o.is_pickable? and (o.locker == nil or o.is_locked?(@nick)))
          # porta in primo piano (carte o deck) se non e' menu
          o.to_front if (m.args[0] == :mouse_left)
          # rinvio del pick a chi l'ha cliccato
          send_me(str)
          unless o.kind_of?(Hand) # e' sempre locked la hand
            o.lock(@nick) # lock oggetto col nick di chi l'ha cliccato
            # rinvio a tutti gli altri del lock dell'oggetto
            resend_without_me(Msg.dump(:type => "Lock", 
                                       :oid => m.oid, 
                                       :args => [m.args[0], @nick]))
          else
            # se hand si tiene temporaneam. i ref delle carte per spostarle
            o.lock_cards(@nick)
          end
        end
      when "Move"
        o = env.get_object(m.oid)
        if o.is_locked?(@nick)
          temp_pos = o.get_pos # serve per le carte sulla mano
          o.set_pos(*m.args) # salva il movimento
          resend_without_me(str) # rinvia agli altri move dell'oggetto
          if o.kind_of?(Hand)
            # sposta tutte le carte con la mano
            o.locked_cards.each do |c|
              pos = [c.x + o.x - temp_pos[0], c.y + o.y - temp_pos[1]]
              c.set_pos(*pos)
              resend_all(Msg.dump(:type => "Move", 
                                  :oid => c.oid,
                                  :args => pos))
            end
          end
        end
      when "UnLock"
        o = env.get_object(m.oid)
        return unless o # nel caso si elimina una carta
                        # non esiste + oggetto da unlockare
        if (not o.kind_of?(Hand) and o.is_locked?(@nick)) # non unlock hand
          # unlock oggetto in pick e comunicazione a tutti gli altri
          o.unlock
          resend_without_me(str)
        end
        hands = cards = []
        if o.kind_of?(Card)
          hands = env.hands.values
          cards.push(o)
        elsif o.kind_of?(Hand)
          # rimuove le carte in links per lo spostamento
          o.unlock_cards
          hands.push(o)
          cards = env.cards
        end
        hands.each do |h|
          cards.each do |c|
            if h.fixed_collide?(c)
              ret = SecretDeck.instance.get_value(c)
              client_id = env.get_key_hand(h)
              send_to(client_id, Msg.dump(:type => "Action", 
                                          :oid => c.oid, 
                                          :args => [:set_value, ret]))
            end
          end
        end
      when "GetValue"
        hand = env.get_hand(self.object_id)
        hand.cards_on.each do |c| 
          ret = SecretDeck.instance.get_value(c)
          send_me(Msg.dump(:type => "Action", 
                           :oid => c.oid, 
                           :args => [:set_value, ret]))
        end
      when "Action"
        o = env.get_object(m.oid)
        if o.is_locked?(@nick)
          if (m.args == :action_shuffle or 
              m.args == :action_turn or 
              m.args.to_s.start_with?("action_create"))
            ret = o.send(m.args) # azione su un oggetto
            resend_all(Msg.dump(:type => "Action", 
                                :oid => m.oid, 
                                :args => [m.args, ret]))
          elsif m.args == :action_take
            hand = env.get_hand(self.object_id)
            pos = [hand.x - 85, hand.y + 42]
            o.cards_near.each do |c|
              c.send(:action_cover) # azione su un oggetto
              resend_all(Msg.dump(:type => "Action", 
                                  :oid => c.oid, 
                                  :args => :action_cover))
              c.send(m.args, pos) # azione su un oggetto
              resend_all(Msg.dump(:type => "Action", 
                                  :oid => c.oid, 
                                  :args => [m.args, pos]))
            end
          elsif m.args == :action_points
            cards = o.cards_near
            cards.each do |c|
              ret = c.send(:action_uncover) # azione su un oggetto
              resend_all(Msg.dump(:type => "Action", 
                                  :oid => c.oid, 
                                  :args => [:action_uncover, ret]))
            end
            cards = env.order_points(cards) # hash di carte riordinate
            y = 0
            cards.each do |k, v|
              x = 0
              v.each do |c|
                c.to_front # azione su un oggetto
                resend_all(Msg.dump(:type => "Action", 
                                    :oid => c.oid, 
                                    :args => :to_front))
                pos = [c.x + x * 20, c.y + y * 30]
                c.send(:action_take, pos) # azione su un oggetto
                resend_all(Msg.dump(:type => "Action", 
                                    :oid => c.oid, 
                                    :args => [:action_take, pos]))
                x += 1
              end
              y += 1
            end
          elsif m.args == :action_to_deck
            cards_code = o.cards_code_near
            env.deck.send(m.args, cards_code) # azione su un oggetto
            resend_all(Msg.dump(:type => "Action", 
                                :oid => env.deck.oid, 
                                :args => [m.args, cards_code]))
          else
            o.send(m.args) # azione su un oggetto
            resend_without_me(str)
          end
        end
      end
    end
  end
  
  # Invia un messaggio al client.
  def send_me(data)
    data = "#{data}#{$DELIM}" unless data.end_with?($DELIM)
    send_data(data)
  end
  
  # Invia un messaggio ad un client preciso.
  def send_to(client_id, data)
    Env.instance.get_client(client_id).send_me(data)
  end
  
  # Invia un messaggio a tutti i client.
  def resend_all(data)
    Env.instance.clients.values.each do |cl|
      cl.send_me(data)
    end
  end
  
  # Invia un messaggio a tutti i client tranne l'attuale.
  def resend_without_me(data)
    Env.instance.clients.values.each do |cl|
      if cl.object_id != self.object_id
        cl.send_me(data)
      end
    end
  end
  
end


if __FILE__ == $0
  
  EventMachine::run do
    s = Server.new
    s.start
    trap("INT") { EventMachine::stop_event_loop }
    puts "Server is running..."
  end
  
end

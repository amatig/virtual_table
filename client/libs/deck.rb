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

class Deck < VObject
  attr_reader :cards_code, :cards_value
  
  def init_graph
    @snd_place = Sound.load("./wavs/place_card.wav")
    @snd_shuffle = Sound.load("./wavs/shuffle.wav")
    # init font
    TTF.setup
    @font = TTF.new("./fonts/FreeSans.ttf", 12)
    # graph
    update_label
    @image = Surface.load("./images/#{@name}/deck1.png")
    @image_empty = Surface.load("./images/#{@name}/deck2.png")
    @image_lock = Surface.load("./images/lock.png")
    @rect = @image.make_rect
    set_pos(@x, @y)
    return self
  end
  
  def update_label
    @label = @font.render_utf8("#{'%02d' % size}/#{@max_size}", true, [255, 255, 255])
  end
  
  def to_front
    Env.instance.to_front(self)
  end
  
  def size
    return @cards_code.size
  end
  
  # Ridefinizione del metodo per il deck.
  def draw(screen)
    unless @cards_code.empty?
      @image.blit(screen, @rect)
    else
      @image_empty.blit(screen, @rect)
    end
    @label.blit(screen, [@rect.x + 43, @rect.y + 113])
    if @lock
      @image_lock.blit(screen, @rect)
      label2 = @font.render_utf8(@lock, true, [255, 255, 255])
      label2.blit(screen, [@rect.x + 1, @rect.y - 17])
    end
  end
  
end

# Menu actions

class Deck
  
  def menu_actions
    return [["1 carta", "action_1card"],
            ["1 carta a testa", "action_1card4all"], 
            ["2 carte a testa", "action_2card4all"], 
            ["3 carte a testa", "action_3card4all"], 
            ["5 carte a testa", "action_5card4all"], 
            ["Mazzo da 40", "action_create40"],
            ["Mazzo da 52", "action_create52"],
            ["Mazzo da 54", "action_create54"],
            ["Mescola", "action_shuffle"]]
  end
  
  def action_1card(x = nil, y = nil)
    unless @cards_code.empty?
      @snd_place.play unless @snd_place.playing?
      c = Card.new(@name, @cards_code.delete(@cards_code.first))
      update_label
      if (x and y)
        c.set_pos(x, y)
      else
        c.set_pos(@x + 90, @y + 2)
      end
      Env.instance.add_object(c)
    end
  end
  
  def action_1card4all(shift = 0)
    Env.instance.objects.each do |o|
      if o.kind_of?(Hand)
        action_1card(o.x + 20 + shift, o.y + 42)
      end
    end
  end
  
  def action_2card4all
    (0..1).each do |n|
      action_1card4all(n * 36)
    end
  end
  
  def action_3card4all
    (0..2).each do |n|
      action_1card4all(n * 36)
    end
  end
  
  def action_5card4all
    (0..4).each do |n|
      action_1card4all(n * 36)
    end
  end
  
  def action_shuffle(data = nil)
    if data
      @snd_shuffle.play
      @cards_code = data
    end
  end
  
  def action_create40(data = nil)
    if data
      @snd_shuffle.play
      Env.instance.del_all_card
      @cards_code = data
      @max_size = size
      update_label
    end
  end
  
  def action_create52(data = nil)
    if data
      @snd_shuffle.play
      Env.instance.del_all_card
      @cards_code = data
      @max_size = size
      update_label
    end
  end
  
  def action_create54(data = nil)
    if data
      @snd_shuffle.play
      Env.instance.del_all_card
      @cards_code = data
      @max_size = size
      update_label
    end
  end
  
  def action_to_deck(data = nil)
    if data
      @snd_place.play
      data.each do |c|
        Env.instance.del_object_by_id(c)
      end
      @cards_code.concat(data)
      update_label
    end
  end
  
end

# Necessario per riconoscere il tipo in UnMarhall

class DeckPoker < Deck  
end

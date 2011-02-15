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

class Card < VObject
  attr_reader :seed, :num
  
  def initialize(deck, code)
    super()
    @oid = code # serve un indice unico
    @deck = deck
    @seed = nil
    @num = nil
    @turn = false
    init_graph
  end
  
  def init_graph
    @@snd_place = Sound.load("./wavs/place_card.wav")
    # init font
    TTF.setup
    @font_lock = TTF.new("./fonts/FreeSans.ttf", 12)
    # graph
    if (@seed == nil and @num == nil)
      @image = Surface.load("./images/#{@deck}/back0.png")
    else
      @image = Surface.load("./images/#{@deck}/#{@seed}#{@num}.png")
    end
    @image_back = Surface.load("./images/#{@deck}/back1.png")
    @image_lock = Surface.load("./images/lock.png")
    @rect = @image.make_rect
    set_pos(@x, @y)
    return self
  end
  
  def set_value(val)
    @seed = val[0]
    @num = val[1]
    @image = Surface.load("./images/#{@deck}/#{@seed}#{@num}.png")
  end
  
  def to_front
    Env.instance.to_front(self)
  end
  
  # Ridefinizione del metodo per il card.
  def draw(screen)
    hand = Env.instance.hand
    if (@turn == false and not hand.rect.collide_rect?(@rect))
      @image_back.blit(screen, @rect)
    else
      @image.blit(screen, @rect)
    end
    if @lock
      @image_lock.blit(screen, @rect)
      label = @font_lock.render_utf8(@lock, true, [255, 255, 255])
      label.blit(screen, [@rect.x + 1, @rect.y - 17])
    end
  end
  
end

# Menu actions

class Card
  
  def menu_actions
    return [["Gira", "action_turn"],
            ["Raccogli", "action_take"],
            ["Metti nel mazzo", "action_to_deck"],
            ["Mostra punti", "action_points"]]
  end
  
  def action_uncover(data = nil)
    if data
      set_value(data)
      @turn = true
    end
  end
  
  def action_cover
    @turn = false
  end
  
  def action_turn(data = nil)
    if data
      @@snd_place.play unless @@snd_place.playing?
      set_value(data)
      @turn = (not @turn)
    end
  end
  
  def action_take(data = nil)
    if data
      @@snd_place.play unless @@snd_place.playing?
      set_pos(*data)
    end
  end
  
  # Metodo fake richiamato poi sul deck.
  def action_to_deck(data = nil)
  end
  
  def action_points(data = nil)
    @@snd_place.play unless @@snd_place.playing?
  end
  
end

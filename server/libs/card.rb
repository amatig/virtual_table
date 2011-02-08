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
  end
  
  def set_value(val)
    @seed = val[0]
    @num = val[1]
  end
  
  def fixed_collide?(card)
    rc1 = Rubygame::Rect.new(@x, @y, 70, 109) # fissi
    rc2 = Rubygame::Rect.new(card.x, card.y, 70, 109) # fissi
    return rc1.collide_rect?(rc2)
  end
  
  def cards_near
    cards = Env.instance.objects.select do |o| 
      o != self and o.kind_of?(Card) and fixed_collide?(o)
    end
    cards.push(self)
    return cards
  end
  
  def cards_code_near
    cards = []
    Env.instance.objects.each do |o| 
      if (o != self and o.kind_of?(Card) and fixed_collide?(o))
        cards.push(o.oid)
      end
    end
    cards.push(@oid)
    return cards
  end
  
  def to_front
    Env.instance.to_front(self)
  end
  
end

# Menu actions

class Card
  
  def action_uncover
    val = SecretDeck.instance.get_value(self)
    set_value(val)
    @turn = true
    return val
  end
  
  def action_cover
    @turn = false
  end
  
  def action_take(data)
    set_pos(*data)
  end
  
  def action_turn
    val = SecretDeck.instance.get_value(self)
    set_value(val)
    @turn = (not @turn)
    return val
  end
  
end

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

class Hand < VObject
  attr_reader :locked_cards
  
  def initialize(nick)
    super()
    @oid = nick
    @lock = nick
    @locked_cards = []
    @x = rand(450) + 100
    @y = rand(320) + 100
  end
  
  def move
  end
  
  def lock_cards(nick)
    unlock_cards
    cards_on.each do |c|
      c.lock(nick)
      # metto gli oggetti tanto solo in pick esistono
      @locked_cards.push(c)
    end
  end
  
  def cards_on
    return Env.instance.objects.select do |c| 
      c.kind_of?(Card) and fixed_collide?(c)
    end
  end
  
  def unlock_cards
    @locked_cards.each { |c| c.unlock }
    @locked_cards = []
  end
  
  def fixed_collide?(card)
    rhd = Rubygame::Rect.new(@x, @y, 315, 175) # fissi
    rc = Rubygame::Rect.new(card.x, card.y, 70, 109) # fissi
    return rhd.collide_rect?(rc)
  end
  
end

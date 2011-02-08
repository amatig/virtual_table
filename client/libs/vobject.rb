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

class VObject
  attr_reader :oid, :x, :y, :rect, :lock
  
  def initialize
    # indice univoco
    @oid = (0...10).collect { rand(10) }.join
    # dati della grafica
    @image = nil
    @image_lock = nil
    @rect = nil
    # coordinate oggetto
    @x = @px = 0 # x e punto x di pick sulla carta
    @y = @py = 0 # y e punto y di pick sulla carta
    # dati vari
    @movable = true
    @pickable = true
    @lock = nil
  end
  
  def init_graph
  end
  
  def to_front
  end
  
  def locker
    return @lock
  end
  
  def lock(nick)
    @lock = nick
  end
  
  def unlock
    @lock = nil
  end
  
  def is_locked?(nick)
    return (@lock == nick)
  end
  
  def is_movable?
    return @movable
  end
  
  def is_pickable?
    return @pickable
  end
  
  def collide?(x, y)
    return @rect.collide_point?(x, y)
  end
  
  def save_pick_pos(x, y)
    if collide?(x, y)
      @px = x - @rect.x
      @py = y - @rect.y
    end
  end
  
  def get_pos
    return [@x, @y]
  end
  
  def set_pos(x, y)
    @rect.topleft = [x, y]
    @x = x
    @y = y
  end
  
  def move(x, y)
    if is_movable?
      temp = @rect.move!(x - @rect.x - @px, y - @rect.y - @py)
      @x = temp.x
      @y = temp.y
      return get_pos
    end
  end
  
  def menu_actions
    return []
  end
  
  def draw(screen)
    @image.blit(screen, @rect)
    @image_lock.blit(screen, @rect) if @lock
  end
  
end

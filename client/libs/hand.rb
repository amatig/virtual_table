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
  
  def init_graph
    # init font
    TTF.setup
    font = TTF.new("./fonts/FreeSans.ttf", 15)
    # label
    @label = font.render_utf8(@lock, true, [255, 255, 255])
    @image = Surface.load("./images/hand1.png")
    @rect = @image.make_rect
    set_pos(@x, @y)
    return self
  end
  
  # Ridefinizione del metodo per la hand.
  def draw(screen)
    @image.blit(screen, @rect)
    @label.blit(screen, [@rect.x + 20, @rect.y + 10])
  end
  
end

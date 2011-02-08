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

class SecretDeck
  include Singleton
  
  def create(deck)
    @secret_cards = {}
    deck.cards_code.each do |code|
      value = deck.cards_value.delete(deck.cards_value.first)
      @secret_cards[code] = value
    end
  end
  
  def get_value(card)
    return @secret_cards[card.oid]
  end
  
end

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

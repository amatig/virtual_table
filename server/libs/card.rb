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
  
  def to_front
    Env.instance.to_front(self)
  end
  
  def action_turnon
    val = SecretDeck.instance.get_value(self)
    set_value(val)
    @turn = true
    return val
  end
  
  def action_turnoff
    @turn = false
  end
  
  def action_turn
    val = SecretDeck.instance.get_value(self)
    set_value(val)
    @turn = (not @turn)
    return val
  end
  
  def action_take(data)
    set_pos(*data)
  end
  
end

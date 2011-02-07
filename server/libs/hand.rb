class Hand < VObject
  attr_accessor :cards
  
  def initialize(nick)
    super()
    @oid = nick
    @lock = nick
    @cards = []
    @x = rand(450) + 100
    @y = rand(320) + 100
  end
  
  def move
  end
  
  def lock_over_cards(nick)
    unlock_over_cards
    over_cards.each do |c|
      c.lock(nick)
      # metto gli oggetti tanto solo in pick esistono
      @cards.push(c)
    end
  end
  
  def over_cards
    return Env.instance.objects.select do |c| 
      c.kind_of?(Card) and fixed_collide?(c)
    end
  end
  
  def unlock_over_cards
    @cards.each { |c| c.unlock }
    @cards = []
  end
  
  def fixed_collide?(card)
    rhd = Rubygame::Rect.new(@x, @y, 315, 175) # fissi
    rc = Rubygame::Rect.new(card.x, card.y, 70, 109) # fissi
    return rhd.collide_rect?(rc)
  end
  
end

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

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
      set_value(data)
      @turn = (not @turn)
    end
  end
  
  def action_take(data = nil)
    set_pos(*data) if data
  end
  
  # Metodo fake richiamato poi sul deck.
  def action_to_deck(data = nil)
  end
  
  def action_points(data = nil)
  end
  
end

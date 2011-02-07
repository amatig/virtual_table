class Hand < VObject
    
  def init_graph
    # init font
    TTF.setup
    font = TTF.new("./fonts/FreeSans.ttf", 20)
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

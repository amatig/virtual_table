class Table < VObject
  
  def init_graph
    @image = Surface.load("./images/#{@name}.jpg")
    @rect = @image.make_rect
    return self
  end
  
  def change_bg(name)
    @name = name
    @image = Surface.load("./images/#{@name}.jpg")
  end
  
  # Ridefinizione del metodo per il table.
  def draw(screen)
    @image.blit(screen, @rect)
  end
  
end

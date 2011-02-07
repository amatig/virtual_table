class Menu
  attr_reader :choice
  
  def initialize(pos, vobject)
    # azione scelta dal menu
    @choice = nil
    # init font
    TTF.setup
    font = TTF.new("./fonts/FreeSans.ttf", 12)
    # dati della grafica
    @image = Surface.load("./images/menu1.jpg")
    @image_sel = Surface.load("./images/menu2.jpg")
    @items = [] # entry del menu
    space = 0
    vobject.menu_actions.each do |label, method|
      t = font.render_utf8(label, true, [0, 0, 0])
      r = @image.make_rect
      r.topleft = [pos[0], pos[1] + space * 20]
      @items.push([t, r, label, method])
      space += 1
    end
  end
  
  def select(ev)
    @items.each do |item|
      if item[1].collide_point?(*ev.pos)
        @choice = item[3]
        break
      else
        @choice = nil
      end
    end
  end
  
  def draw(screen)
    @items.each do |item|
      if choice == item[3]
        @image_sel.blit(screen, item[1])
      else
        @image.blit(screen, item[1])
      end
      item[0].blit(screen, [item[1][0] + 5, item[1][1] + 3])
    end
  end
  
end

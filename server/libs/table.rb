class Table < VObject
  
  def initialize
    super()
    @name = "table1"
    @movable = false
    @pickable = false
  end
  
  def change_bg(name)
    @name = name
  end
  
end

class Msg
  attr_accessor :type, :oid, :action, :args, :data
  
  def self.dump(args = {})
    m = Msg.new
    m.type = args[:type]
    m.oid = args[:oid]
    m.action = args[:action]
    m.args = args[:args]
    m.data = args[:data]
    return Marshal.dump(m)
  end
  
  def self.load(data)
    return Marshal.load(data)
  end
  
end

class Env
  include Singleton
  attr_reader :clients, :table, :deck, :objects, :hash_objects, :hands
  
  def initialize
    @clients = {} # connessioni socket dei client
    @table = nil
    @deck = nil
    @objects = [] # lista oggetti sul tavolo
    @hash_objects = {} # per accedere agli oggetti + velocemente
    @hands = {}
  end
  
  def add_client(conn)
    @clients[conn.object_id] =  conn
  end
  
  def del_client(conn)
    @clients.delete(conn.object_id)
  end
  
  def del_client_by_id(client_id)
    @clients.delete(client_id)
  end
  
  def get_client(client_id)
    return @clients[client_id]
  end
  
  def add_table(o)
    @table = o
    return o
  end
  
  def set_deck(o)
    @deck = o
    return o
  end
  
  def add_hand(client_id, o)
    @hands[client_id] = add_first_object(o)
    return o
  end
  
  def get_hand(client_id)
    return @hands[client_id]
  end
  
  def get_key_hand(o)
    return @hands.index(o)
  end
  
  def del_hand(o)
    del_object(o)
    @hands.delete(get_key_hand(o))
    return o
  end
  
  def del_hand_by_id(client_id)
    o = get_hand(client_id)
    del_hand(o)
    return o
  end
  
  def add_object(o)
    @objects.push(o)
    @hash_objects[o.oid] = o
    return o
  end
  
  def add_first_object(o)
    @objects.insert(0, o)
    @hash_objects[o.oid] = o
    return o
  end
  
  def del_object(o)
    @hash_objects.delete(o.oid)
    return @objects.delete(o)
  end
  
  def del_object_by_id(oid)
    return del_object(get_object(oid))
  end
  
  def del_all_card
    @hash_objects.keys.each do |oid|
      o = get_object(oid)
      del_object(o) if o.kind_of?(Card)
    end
  end
  
  def order_points(cards)
    temp = {}
    cards.each do |c|
      temp[c.seed] ||= []
      temp[c.seed].push(c)
    end
    return temp
  end
  
  def to_front(o)
    @objects.push(@objects.delete(o))
  end
  
  def get_object(oid)
    return @hash_objects[oid]
  end
  
end

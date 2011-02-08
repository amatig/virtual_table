# Classe.
# = Description
# Classe.
# = License
# Virtual Table - Tavolo da gioco virtuale
#
# Copyright (C) 2011 Giovanni Amati
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
# = Authors
# Giovanni Amati

class Env
  include Singleton
  attr_reader :table, :objects, :hash_objects, :hand
  attr_accessor :flag
  
  def initialize
    @table = nil
    @objects = [] # lista oggetti sul tavolo
    @hash_objects = {} # per accedere agli oggetti + velocemente
    @hand = nil
    @flag = false # dice se si deve ridisegnare o no
  end
  
  def add_table(o)
    @table = o
    return o
  end
  
  def add_hand(o)
    @hand = o
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
  
  def get_object(oid)
    return @hash_objects[oid]
  end
  
  def del_all_card
    @hash_objects.keys.each do |oid|
      o = get_object(oid)
      del_object(o) if o.kind_of?(Card)
    end
  end
  
  def to_front(o)
    @objects.push(@objects.delete(o))
  end
  
end

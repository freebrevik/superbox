# The MIT License (MIT)
# Copyright (c) 2013 Cory Brevik
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SBXQuery
  
  def initialize(entity)
    @entity_name = entity
    @context = nil
    @predicate = nil
    @order_dict = nil
  end
  
  def all
    result = nil
    if @predicate.nil? then
      result = NSFetchRequest.fetchObjectsForEntityForName(@entity_name, top: nil, order: @order_dict, inManagedObjectContext: SuperBox::Core.context)
    else
      result = NSFetchRequest.fetchObjectsWithPredicate(@entity_name, predicate: @predicate, top: nil, order: @order_dict, inManagedObjectContext: SuperBox::Core.context)
    end
    result
  end
  def remove
    NSFetchRequest.removeObjectsWithPredicate(@entity_name, predicate: @predicate, inManagedObjectContext: SuperBox::Core.context)
  end
  def remove_all
    NSFetchRequest.removeObjectsForEntityForName(@entity_name, inManagedObjectContext: SuperBox::Core.context)
  end
  def single
    result = nil
    if @predicate.nil? then
      result = NSFetchRequest.fetchObjectsForEntityForName(@entity_name, top: 1, order: @order_dict, inManagedObjectContext: SuperBox::Core.context)
    else
      result = NSFetchRequest.fetchObjectsWithPredicate(@entity_name, predicate: @predicate, top: 1, order: @order_dict, inManagedObjectContext: SuperBox::Core.context)
    end
    if result.size == 1
      return result.first
    end
    result
  end
  
  def top(limit)
    result = nil
    if @predicate.nil? then
      result = NSFetchRequest.fetchObjectsForEntityForName(@entity_name, top: limit, order: @order_dict, inManagedObjectContext: SuperBox::Core.context)
    else
      result = NSFetchRequest.fetchObjectsWithPredicate(@entity_name, predicate: @predicate, top: limit, order: @order_dict, inManagedObjectContext: SuperBox::Core.context)
    end
    result
  end
  
  def count
    result = 0
    if @predicate.nil? then
      result = NSFetchRequest.countEntitiesForName(@entity_name, inManagedObjectContext: SuperBox::Core.context)
    else
      result = NSFetchRequest.countEntitiesWithPredicate(@entity_name, predicate: @predicate, inManagedObjectContext: SuperBox::Core.context)
    end
    result
  end
  
  def order_by(dict={})
    @order_dict = dict
    self
  end
  
  def where(predicate)
    @predicate = predicate
    self
  end
end


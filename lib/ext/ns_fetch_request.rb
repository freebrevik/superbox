class NSFetchRequest

  def self.buildOrderDescriptors(order_dict = {})
    #here's where you specify the sort

    descriptors = []
    order_dict.each do |key,value|
      descriptors << sort_desc = NSSortDescriptor.alloc.initWithKey(key.to_s, ascending: (value == :asc))
    end
    descriptors
  end

  def self.removeObjectsForEntityForName(entityName, inManagedObjectContext: context)
    data = fetchObjectsForEntityForName(entityName,top: nil, order: nil, inManagedObjectContext:context)
    if not data.nil? then
      data.each do |object|
        object.remove
      end
    end
    true
  end
  def self.removeObjectsWithPredicate(entityName, predicate: predicate, inManagedObjectContext: context)
    data = fetchObjectsWithPredicate(entityName, predicate: predicate, top: nil, order: nil, inManagedObjectContext: context)
    if not data.nil? then
      data.each do |object|
        object.remove
      end
    end
    true
  end
  def self.fetchObjectsForEntityForName(entityName, top: limit, order: order_dict, inManagedObjectContext:context)

    request = self.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)

    request.setFetchLimit(limit) if not limit.nil?

    request.setSortDescriptors(buildOrderDescriptors(order_dict)) if not order_dict.nil?

    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.fetchObjectsWithPredicate(entityName, predicate: predicate, top: limit, order: order_dict,  inManagedObjectContext:context)

    request = self.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)
    request.setPredicate(predicate)

    request.setFetchLimit(limit) if not limit.nil?

    request.setSortDescriptors(buildOrderDescriptors(order_dict)) if not order_dict.nil?

    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.countEntitiesForName(entityName, inManagedObjectContext:context)
    request = self.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)

    error_ptr = Pointer.new(:object)
    count = context.countForFetchRequest(request, error: error_ptr)
    if count == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    count
  end

  def self.countEntitiesWithPredicate(entityName, predicate: predicate, inManagedObjectContext:context)
    request = self.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)
    request.setPredicate(predicate)

    error_ptr = Pointer.new(:object)
    count = context.countForFetchRequest(request, error: error_ptr)
    if count == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    count
  end


end
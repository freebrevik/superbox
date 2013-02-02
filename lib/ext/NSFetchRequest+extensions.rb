class NSFetchRequest
  
  def self.fetchObjectsForEntityForName(entityName, inManagedObjectContext:context)
    
    request = self.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end
  
end
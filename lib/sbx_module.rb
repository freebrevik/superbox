SBX = SuperBox unless defined?(SBX)
module SuperBox
  module Core
    module_function

    @models = []
    
    def self.included(mod)
      @models << mod
      
      if not SuperBox.constants.include?(mod.name)
        SuperBox.const_set mod.name.pluralize , SBXQuery.new(mod.name)
      end
    end
    
    def open
      yield data
      data.save
    end
      
    def context
      data.context
    end
    
    def dump
      data.dump
    end
    
    def heavy_migrate
      
      @instance.clear
      @instance = nil
      
      dir = File.join(NSHomeDirectory(), 'Documents', "model")
      box_name = "sbx_#{Time.new}"
                #move new box to old box's location
      error_ptr = Pointer.new(:object)
      unless NSFileManager.defaultManager.moveItemAtPath(File.join(dir,"sbx.sqlite"),toPath: File.join(dir,box_name + ".sqlite") , error: error_ptr)
        raise "Failed to rename store: #{error_ptr[0].description}"
      end
      unless NSFileManager.defaultManager.moveItemAtPath(File.join(dir,"sbx.mod"),toPath: File.join(dir,box_name + ".mod") , error: error_ptr)
        raise "Failed to rename model: #{error_ptr[0].description}"
      end
      
      options = {:file_path => "/model", :auto_migrate => false, :backup_data => false } 
      other_data = SBXInstance.make(box_name,nil,options)
      

      data
      
      yield other_data
      other_data.clear
    end
    
    def delete_all
      data.delete
      @instance = nil
    end
    
    def save
      data.save
    end
    
    def data
      if @instance.nil? then
        options = {:file_path => "/model", :auto_migrate => true, :backup_data => true } 
        @instance = SBXInstance.make("sbx",@models,options)
      end
      @instance
    end
  end
end

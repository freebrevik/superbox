# The MIT License (MIT)
# Copyright (c) 2013 Cory Brevik
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module SuperBox
  module Core
    class SBXInstance
      attr_accessor :schemas
      attr_accessor :context
      attr_accessor :store
      attr_accessor :model
      attr_accessor :name
      attr_accessor :coordinator


      def self.shared(box)
        @instance ||= {}
        @instance[box] ||= new(box)
      end

      #holds a box
      def self.make(box, p, options = {})
        s = nil
        s = self.shared(box)
        s.create_box(box,options,p)
        s
      end

      def self.delete_all
        @instance.each do |key, value|
          value.delete
        end
      end

      def create(object)
        return object.create_with_context(@context)
      end

      def all(object)
        return object.all(@context)
      end

      def dump
        @schemas.each do |s|
          objects = s.all(@context)
          puts
          puts "#{s.name.pluralize}"
          if objects.empty? then puts "Empty" end
            objects.each do |o|
              puts "Name: #{o.properties.name} ID:" + "#{o.objectID.URIRepresentation.absoluteString}"
              o.properties.propertiesByName.each do |key, value|
                valString = ""
                val = o.send(key)
                if val == nil then
                  valString = "nil"
                else
                  valString = "#{val}"
                end
                puts "#{key}" + ": \"" + valString + "\""
              end
              puts
            end
          end
        end

        def create_box(box, options = {}, p = [])

          @options = options || {}

          @options[:auto_migrate] = true if @options[:auto_migrate].nil?
          @options[:file_path] = "" if @options[:file_path].nil?
          @options[:backup_data] = 0 if @options[:backup_data].nil?

          unless @model.nil?
            raise "This box already exists."
          end

          @schemas = p

          @working_directory = File.join(NSHomeDirectory(), 'Documents', @options[:file_path])

          error_ptr = Pointer.new(:object)
          directory_exists = NSFileManager.defaultManager.createDirectoryAtURL(NSURL.fileURLWithPath(@working_directory),withIntermediateDirectories: true, attributes: nil, error: error_ptr)
          unless directory_exists
            raise "Can not create directory for box: #{error_ptr[0].description}"
          end

          if not @options[:backup_data].nil? and @options[:backup_data] then
            error_ptr = Pointer.new(:object)
            directory_exists = NSFileManager.defaultManager.createDirectoryAtURL(NSURL.fileURLWithPath(File.join(@working_directory, "Backup")),withIntermediateDirectories: true, attributes: nil, error: error_ptr)
            unless directory_exists
              raise "Can not create directory for box: #{error_ptr[0].description}"
            end
          end

          need_update = false

          #check if model is already exists on disk
          if model_exists then
            #check if model is different from the one defined in code
            need_update = any_updates?
            #load model
            @model = load_model
          else
            #create model and save it to file
            @model = create_model_with_file
          end

          #create store
          create_store

          #if update needed, perform migration
          if need_update and @options[:auto_migrate] == true then
            if not @options[:backup_data].nil? and @options[:backup_data] then
              backup
            end

            migrate
          end
        end

        def migrate
          #pointer for handling errors
          error_ptr = Pointer.new(:object)

          #must migrate to a path that doesn't exist
          new_store_url = NSURL.fileURLWithPath(File.join(@working_directory, @name + "new.sqlite"))
          #path to store you are migrating from
          old_store_url = NSURL.fileURLWithPath(File.join(@working_directory, @name + ".sqlite"))

          #create most recent model
          new_model = create_model

          #Try to get an inferred mapping model.
          mapping = NSMappingModel.inferredMappingModelForSourceModel(@model, destinationModel: new_model, error:error_ptr)

          #If Core Data cannot create an inferred mapping model, return NO.
          if (!mapping)
            return false;
          end

          #Create a migration manager to perform the migration.
          manager = NSMigrationManager.alloc.initWithSourceModel(@model, destinationModel: new_model)
          unless manager.migrateStoreFromURL(old_store_url, type:NSSQLiteStoreType,
            options: nil, withMappingModel:mapping, toDestinationURL: new_store_url,
            destinationType:NSSQLiteStoreType, destinationOptions:nil, error:error_ptr)
            raise "Migration failed: #{error_ptr[0].description}"
          end


          #remove old box
          self.delete
          #end

          #move new box to old box's location
          unless NSFileManager.defaultManager.moveItemAtPath(new_store_url.path,toPath:old_store_url.path, error: error_ptr)
            raise "Failed to rename new box: #{error_ptr[0].description}"
          end

          #set to new model
          @model = new_model

          #save new model
          unless NSKeyedArchiver.archiveRootObject(@model, toFile:File.join(NSHomeDirectory(), 'Documents', @name + ".mod"))
            raise "Failed to save new model."
          end

          #create new store
          create_store
          return true;
        end

        def backup
          # backup_store_path = File.join(@working_directory, "Backup", @name + "_backup_#{Time.new}.sqlite")
          # backup_exists = NSFileManager.defaultManager.fileExistsAtPath(backup_store_path)
          # error_ptr = Pointer.new(:object)
          # unless NSFileManager.defaultManager.moveItemAtPath(@store.URL,toPath:backup_store_path, error: error_ptr)
          #   raise "Failed to rename new box: #{error_ptr[0].description}"
          # end
        end

        def save
          error_ptr = Pointer.new(:object)
          unless @context.save(error_ptr)
            raise "Error when saving changes: #{error_ptr[0].description}"
          end
          true
        end

        def self.clear
          #@store.persistentStores.each do |st|
        end
        def clear
          if @context != nil
            @context.lock
            @context.reset
          end

          unless @coordinator.removePersistentStore(@store, error:nil)
            raise "Can't remove store: #{error_ptr[0].description}"
          end

          if @context != nil
            @context.unlock
          end
          if @store != nil
            @store = nil
          end
          if @coordinator != nil
            @coordinator = nil
          end
          if @context != nil
            @context = nil
          end
          if @model
            @model = nil
          end
          @options = nil
        end

        def delete
          if @context != nil
            @context.lock
            @context.reset
          end
          error_ptr = Pointer.new(:object)

          unless @coordinator.removePersistentStore(@store, error:error_ptr)
            raise "Can't remove store: #{error_ptr[0].description}"
          end

          unless NSFileManager.defaultManager.removeItemAtPath(@store.URL.path, error:error_ptr)
            raise "Can't remove store file: #{error_ptr[0].description}"
          end

          model_file_path = File.join(@working_directory, @name + ".mod")

          model_file_exists = NSFileManager.defaultManager.fileExistsAtPath(model_file_path)
          
          if model_file_exists then
            unless NSFileManager.defaultManager.removeItemAtPath(model_file_path, error:error_ptr)
              raise "Can't remove model file: #{error_ptr[0].description}"
            end
          end
          if @context != nil
            @context.unlock
          end
          if @store != nil
            @store = nil
          end
          if @coordinator != nil
            @coordiantor = nil
          end
          if @context != nil
            @context = nil
          end
          if @model
            @model = nil
          end
          @options = nil
        end

        def create_store
          store_url = NSURL.fileURLWithPath(File.join(@working_directory, @name + ".sqlite"))

          @coordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(@model)
          error_ptr = Pointer.new(:object)
          @store = @coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:store_url, options:nil, error:error_ptr)
          unless @store
            raise "Failed to add store: #{error_ptr[0].description}"
          end
          context = NSManagedObjectContext.alloc.init
          context.persistentStoreCoordinator = @coordinator
          @context = context
        end

        def any_updates?
          user_model = load_model
          store_url = NSURL.fileURLWithPath(File.join(@working_directory, @name + ".sqlite"))
          error_ptr = Pointer.new(:object)
          #compare meta data to determine if this model is different
          meta_data = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL:store_url, error:error_ptr);
          same = user_model.isConfiguration(nil, compatibleWithStoreMetadata: meta_data)
          return(not same)
        end

        def model_exists
          error_ptr = Pointer.new(:object)
          file_url = NSURL.fileURLWithPath(File.join(@working_directory, @name + ".mod"))
          file_exists = file_url.checkResourceIsReachableAndReturnError(error_ptr)
          file_exists
        end

        def load_model
          model = NSKeyedUnarchiver.unarchiveObjectWithFile(File.join(@working_directory, @name + ".mod"))
          
          @schemas = []
          model.entities.each do |entity|
            @schemas << Kernel.const_get(entity.name)
          end
          
          model
        end

        def create_model
          model = SBXManagedObjectModel.new(@schemas)
          return model
        end

        def create_model_with_file
          model = create_model
          path =  File.join(@working_directory, @name + ".mod")
          result = NSKeyedArchiver.archiveRootObject(model, toFile:path)
          return model
        end

        def initialize(box)
          @name = box
          @model = nil
          @store = nil
          @coordinator = nil
          @context = nil
          @options = nil
          @verbose = true
          @working_directory = ""
        end
      end
    end
  end

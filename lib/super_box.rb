# The MIT License (MIT)
# Copyright (c) 2013 Cory Brevik
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SuperModel < NSManagedObjectModel
  def initialize(p=[])
    self.init
    self.entities = p.map {|c| c.entity}
    self.entities.each do |entity|
      entity.relationshipsByName.values.flatten.each do |property|
        property.destinationEntity = self.entitiesByName[property.destinationEntityName]
        property.inverseRelationship = property.destinationEntity.relationshipsByName[property.inverseRelationshipName]
      end
    end
  end
end

class SuperObject < NSManagedObject

  CoreTypes = {
    NSInteger16AttributeType => 0,
    NSInteger32AttributeType => 0,
    NSInteger64AttributeType => 0,
    NSDecimalAttributeType => 0.0,
    NSDoubleAttributeType => 0.0,
    NSFloatAttributeType => 0.0,
    NSStringAttributeType => '',
    NSBooleanAttributeType => false,
    NSDateAttributeType => nil,
    NSBinaryDataAttributeType => nil,
    NSTransformableAttributeType => nil,
    NSObjectIDAttributeType => nil
  }

  def self.property(property = {})
    @properties ||= []
    @relationships ||= []
    return nil if property.empty?

    if property[:type] == "relationship" then @relationships.push(property)
    else @properties.push(property)
    end
  end

  def properties
    return self.entity
  end

  def self.entity
    @entity = NSEntityDescription.alloc.init.tap do |e|
      e.name = name
      e.managedObjectClassName = name

      attributes = @properties.map do |att|
        property = NSAttributeDescription.alloc.init
        property.name = att[:name]
        property.attributeType = att[:type] || NSStringAttributeType
        property.defaultValue = att[:default] || CoreTypes[att[:type] || NSStringAttributeType]
        property.optional = att[:optional] || false
        property.transient = att[:transient] || false
        property.indexed = att[:indexed] || false
        property
      end

      connections = @relationships.map do |rel|
        property = NSRelationshipDescription.alloc.init
        property.name = rel[:name]
        property.destinationEntityName = rel[:destination]
        property.inverseRelationshipName = rel[:inverse] || ""
        property.optional = rel[:optional] || false
        property.transient = rel[:transient] || false
        property.indexed = rel[:indexed] || false
        property.ordered = rel[:ordered] || false
        property.minCount = rel[:min] || 1
        property.maxCount = rel[:max] || 1 # NSIntegerMax
        property.deleteRule = rel[:del] || NSNullifyDeleteRule # NSNoActionDeleteRule NSNullifyDeleteRule NSCascadeDeleteRule NSDenyDeleteRule
        property
      end

      e.properties = attributes + connections
    end
  end

  def self.all(context)
    @objects = NSFetchRequest.fetchObjectsForEntityForName(name, inManagedObjectContext:context)
  end

  #creates a description
  def self.create(context)
    NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext:context)
  end

  #overload new to return NSEntityDescription
  def self.new(context)
    self.create(context)
  end

  def remove(context)
    SuperBox.context.deleteObject(self)
  end

  def managedObjectClass
    puts "#{NSClassFromString(self.entity.managedObjectClassName)}"
    NSClassFromString(self.entity.managedObjectClassName)
  end
end

class User < SuperObject
  property :name => "name", :type => NSStringAttributeType, :optional => true
  property :name => "created_by", :type => NSStringAttributeType
  property :name => "password", :type => NSStringAttributeType
  property :name => "dogs", :type => "relationship", :destination => "Dog", :min => 0, :max => NSIntegerMax, :del => NSCascadeDeleteRule
end

class Dog < SuperObject
  property :name => "name", :type => NSStringAttributeType, :optional => true
end

class Cat < SuperObject
  property :name => "name", :type => NSStringAttributeType, :optional => true
end

class SuperBox

  attr_accessor :name
  attr_accessor :schemas
  attr_accessor :context
  attr_accessor :model
  attr_accessor :store

  def create(object)
    return object.new(@context)
  end

  def all(object)
    return object.all(@context)
  end

  def dump
    @schemas.each do |s|
      objects = s.all(@context)
      puts ""
      puts "#{s.name}s"
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
        puts ""
      end
    end
  end

  def self.open(box = "super")
    puts "Opening SuperBox named: #{box}"
    yield self.instance(box)
    self.instance(box).save
  end

  def self.instance(box = "super")
    @instance ||= {}
    @instance[box] ||= new(box)
  end

  #holds a box
  def self.holds(box = "super", *p)
    s = self.instance(box)

    unless s.model.nil?
      raise "This box already exists."
    end

    puts "Creating SuperBox named: #{box}, with schemas: #{p}"
    s.schemas = p

    need_update = false

    #check if model is already exists on disk
    if s.model_exists then
      #check if model is different from the one defined in code
      need_update = s.any_updates?

      #load model
      s.model = s.load_model
      puts "Loaded model with entities: #{s.model.entitiesByName}"
    else

      #create model and save it to file
      s.model = s.create_model_with_file
      puts "Created model with entities: #{s.model.entitiesByName}"
    end

    #create store
    s.create_store
    puts "Need update? #{need_update ? "Yes" : "No"}"

    #if update needed, perform migration
    if need_update then
      s.migrate
    end
    s
  end

  def migrate
    #pointer for handling errors
    error_ptr = Pointer.new(:object)

    puts "Starting SuperBox migration..."

    #must migrate to a path that doesn't exist
    new_store_url = NSURL.fileURLWithPath(File.join(NSHomeDirectory(), 'Documents', @name + "new.sqlite"))
    #path to store you are migrating from
    old_store_url = NSURL.fileURLWithPath(File.join(NSHomeDirectory(), 'Documents', @name + ".sqlite"))

    #create most recent model
    new_model = create_model

    #Try to get an inferred mapping model.
    mapping = NSMappingModel.inferredMappingModelForSourceModel(@model, destinationModel: new_model, error:error_ptr)

    #If Core Data cannot create an inferred mapping model, return NO.
    if (!mapping)
      puts "Migration failed, can not infer mapping."
      return false;
    end

    #Create a migration manager to perform the migration.
    manager = NSMigrationManager.alloc.initWithSourceModel(@model, destinationModel: new_model)
    unless manager.migrateStoreFromURL(old_store_url, type:NSSQLiteStoreType,
      options: nil, withMappingModel:mapping, toDestinationURL: new_store_url,
      destinationType:NSSQLiteStoreType, destinationOptions:nil, error:error_ptr)
      raise "Migration failed: #{error_ptr[0].description}"
    end

    puts "Migration complete!"

    #remove old box
    self.delete

    puts "Removed old box at #{old_store_url.path}"

    #move new box to old box's location
    unless NSFileManager.defaultManager.moveItemAtPath(new_store_url.path,toPath:old_store_url.path, error: error_ptr)
      raise "Failed to rename new box: #{error_ptr[0].description}"
    end

    puts "Renamed new box..."
    #set to new model
    @model = new_model

    #save new model
    unless NSKeyedArchiver.archiveRootObject(@model, toFile:File.join(NSHomeDirectory(), 'Documents', @name + ".mod"))
      raise "Failed to save new model."
    end

    puts "Saved old model..."

    #create new store
    create_store
    puts "Created new store"
    return true;
  end


  def save
    error_ptr = Pointer.new(:object)
    unless @context.save(error_ptr)
      raise "Error when saving changes: #{error_ptr[0].description}"
    end
  end

  def clear
    if @context != nil
      @context.lock
      @context.reset
    end
    @store.persistentStores.each do |st|
      unless @store.removePersistentStore(st, error:nil)
        raise "Can't remove store: #{error_ptr[0].description}"
      end
    end
    if @context != nil
      @context.unlock
    end
    if @store != nil
      @store = nil
    end
    if @context != nil
      @context = nil
    end
    if @model
      @model = nil
    end
  end

  def delete
    if @context != nil
      @context.lock
      @context.reset
    end
    @store.persistentStores.each do |st|
      unless @store.removePersistentStore(st, error:nil)
        raise "Can't remove store: #{error_ptr[0].description}"
      end

      unless NSFileManager.defaultManager.removeItemAtPath(st.URL.path, error:nil)
        raise "Can't remove store file: #{error_ptr[0].description}"
      end
    end
    if @context != nil
      @context.unlock
    end
    if @store != nil
      @store = nil
    end
    if @context != nil
      @context = nil
    end
    if @model
      @model = nil
    end
  end

  def create_store
    store_url = NSURL.fileURLWithPath(File.join(NSHomeDirectory(), 'Documents', @name + ".sqlite"))

    @store = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(@model)
    error_ptr = Pointer.new(:object)
    unless @store.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:store_url, options:nil, error:error_ptr)
      raise "Failed to add store: #{error_ptr[0].description}"
    end
    context = NSManagedObjectContext.alloc.init
    context.persistentStoreCoordinator = @store
    @context = context
    #if any_updates? then migrate end
  end

  def any_updates?
    user_model = create_model
    store_url = NSURL.fileURLWithPath(File.join(NSHomeDirectory(), 'Documents', @name + ".sqlite"))
    error_ptr = Pointer.new(:object)
    #compare meta data to determine if this model is different
    meta_data = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL:store_url, error:error_ptr);
    same = user_model.isConfiguration(nil, compatibleWithStoreMetadata: meta_data)
    not same
  end

  def model_exists
    error_ptr = Pointer.new(:object)
    file_url = NSURL.fileURLWithPath(File.join(NSHomeDirectory(), 'Documents', @name + ".mod"))
    file_exists = file_url.checkResourceIsReachableAndReturnError(error_ptr)
    file_exists
  end

  def load_model
    puts "Loading model..."
    return NSKeyedUnarchiver.unarchiveObjectWithFile(File.join(NSHomeDirectory(), 'Documents', @name + ".mod"))
  end

  def create_model
    model = SuperModel.new(@schemas)
    return model
  end

  def create_model_with_file
    model = create_model
    NSKeyedArchiver.archiveRootObject(model, toFile:File.join(NSHomeDirectory(), 'Documents', @name + ".mod"))
    return model
  end

  def initialize(box)
    @name = box
    @model = nil
    @store = nil
    @context = nil
    @verbose = true
  end

end

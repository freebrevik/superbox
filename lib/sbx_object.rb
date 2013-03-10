# The MIT License (MIT)
# Copyright (c) 2013 Cory Brevik
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SBXManagedObject < NSManagedObject

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

  def self.string(symbol)
    property({:name => symbol.to_s, :type => NSStringAttributeType, :optional => true})
  end
  
  def self.date(symbol)
    property({:name => symbol.to_s, :type => NSDateAttributeType, :optional => true})
  end
  
  def self.bool(symbol)
    property({:name => symbol.to_s, :type => NSBooleanAttributeType, :optional => true})
  end
  
  def self.integer(symbol)
    property({:name => symbol.to_s, :type => NSInteger32AttributeType, :optional => true})
  end
  
  def self.double(symbol)
    property({:name => symbol.to_s, :type => NSDoubleAttributeType, :optional => true})
  end
  
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
    @objects = NSFetchRequest.fetchObjectsForEntityForName(name, top: nil, order: nil, inManagedObjectContext:context)
  end

  def self.create(attributes={})
    if self < SuperBox::Core then
      object = self.create_with_context(SuperBox::Core.context)
      attributes.each do |key, value|  
        object.send("#{key}=", value) if object.respond_to? key.to_sym
      end
      return object
    end
    nil
  end
  #creates a description
  def self.create_with_context(context)
    NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext:context)
  end

  def to_s
    a = []
    self.entity.properties.map do |attr|
      a << "#{attr.name} => \"#{self.send(attr.name)}\""
    end
    self.entity.name + " {" + a.join(', ') + "}"
  end
  def remove()
    remove_with_context(SuperBox::Core.context)
  end
  def remove_with_context(context)
    context.deleteObject(self)
  end
  def managedObjectClass
    puts "#{NSClassFromString(self.entity.managedObjectClassName)}"
    NSClassFromString(self.entity.managedObjectClassName)
  end
end

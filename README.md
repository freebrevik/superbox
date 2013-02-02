superbox v. 0.1
========

##Core Data Wrapper for rubymotion.

**Special Credit:**
I want to give special credit to caramdache: https://github.com/caramdache/games,
his example on relationships with core data helped me a lot on learning how to create ManagedObjectModels dynamically.

SuperBox is experimental at the moment, I wouldn't recommend using it in a project yet, but feel free to salvage code for your own project or fork and contribute! Everything here is subject to massive changes.  I am using SuperBox for a game I am making for the IPhone and will update it regularly.

**Current Features:**

- Light Migration. SuperBox will automatically migrate your data when your model changes.
- Persisted Dynamic NSManagedObjectModels. You design your class in code instead of using xcode's model tool. SuperBox will persist this model and look for changes when loading.

**Goals for SuperBox:**

- Allow multiple stores to be open at once. This will be realaly useful when a heavy migration is needed, when your model has changed so much light migration is not possible.
- Encryption. SuperBox will have an encryption feature, where all of your data for a class is automatically encrypted and decrypted. In the case of my game, I don't want user's to be able to change
  game data easily.
- Lazy Filters. SuperBox will have filters that won't access the disk until you want them to.

##Get It:

Download as zip or clone it.

##How To Use:

###Create Model:

```ruby
class User < SuperObject
  property :name => "name", :type => NSStringAttributeType, :optional => true
  property :name => "created_by", :type => NSStringAttributeType
  property :name => "password", :type => NSStringAttributeType
end
```

#Create Super Box:

```ruby
#create a super box, including its name, and model classes
box = SuperBox.holds("super",User)

#create a user object
user = box.create User
user.name = "awdogsgo2heaven"
user.password = "rubymotion"

#save box
box.save
```

###Migration:

Migration is automatic. If your model changes later, when you create your Super Box, it will automatically detect their is a new version
It will then attempt to migrate the existing data to a new store and replace the old one.

###License:

The MIT License (MIT)
Copyright (c) 2013 Cory Brevik

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.






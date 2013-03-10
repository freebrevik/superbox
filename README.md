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
- Filters.

**Goals for SuperBox:**

- Encryption. SuperBox will have an encryption feature, where all of your data for a class is automatically encrypted and decrypted. In the case of my game, I don't want user's to be able to change
  game data easily.

##Get It:

Download as zip or clone it.

##How To Use:

###Create Model:

Models are created by subclassing SBXManagedObject. If you want the model to be part of your main core data model you must include
SuperBox::Core to it, otherwise it will be ignored. 

```ruby
class User < SBXManagedObject
  include SuperBox::Core
  
  property :name => "name", :type => NSStringAttributeType, :optional => true
  property :name => "created_by", :type => NSStringAttributeType
  property :name => "password", :type => NSStringAttributeType
end
```

```ruby
class User < SBXManagedObject
  include SuperBox::Core
  
  string :name
  string :created_by
  string :password
end
```

###Use it:

```ruby

#create a user object
user = User.create()
user.name = "awdogsgo2heaven"
user.password = "rubymotion"

#or you can

user = User.create(:name => "awdogsgo2heaven", :password => "rubymotion")

#Saves everything
SuperBox::Core.save
```

###Filters:

You can query/filter your models by accessing them under the namespace SuperBox. Example:

```ruby
SuperBox::Users.all
```
This will return all users

```ruby
SuperBox::Users.single
#or
SuperBox::Users.top(1)
```
Returns the first User in the list

```ruby
SuperBox::Users.order_by(:name => :asc).single
#or
SuperBox::Users.order_by(:name => :desc, :password => :desc).top(1)
```
Orders a list in asc, or desc by column

```ruby
SuperBox::Users.count()
```
Returns the number of users


###Migration:

Light-Migration is automatic. If your model changes later, when you create your Super Box, it will automatically detect their is a new version
It will then attempt to migrate the existing data to a new store and replace the old one.  

###Other APIs:

```ruby
SuperBox::Core.dump 
```
Puts the entire db into console. 

```ruby
SuperBox::Core.clear 
```
This will clear/remove everything from your db, empty it

```ruby
SuperBox::Core.delete_all
```
Deletes the model and sqlite file from the disk

###License:

The MIT License (MIT)
Copyright (c) 2013 Cory Brevik

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.






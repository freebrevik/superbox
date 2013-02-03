# The MIT License (MIT)
# Copyright (c) 2013 Cory Brevik
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    
    #create a super box, including its name, and model classes
    box = SuperBox.holds("superv2",User,Dog)
    
    #create a user object
    user = box.create User
    user.name = "awdogsgo2heaven"
    user.password = "rubymotion"
    
    #create new dog object
    dog = box.create Dog
    dog.name = "Galileo"
    
    user.addDogsObject(dog)
    
    #save box
    box.save
    
    user = box.create User
    user.name = "awesomecat"
    user.password = "rubymotion"
    
    box.save
    
    user = box.create User
    user.name = "cutekitty"
    user.password = "rubymotion"
    

    
    
    box.save
    
    #dump all the data
    box.dump
    
    box.clear
    
    #create same box, with new model and migrate
    box = SuperBox.holds("superv2",User,Dog,Cat)
    
    #verify migration worked
    box.dump
    
    #create new dog object
    dog = box.create Dog
    dog.name = "Galileo"
    
    box.save
    
    box.dump
    
    #open second box
    other_box = SuperBox.holds("super",User,Dog,Cat)
    
    other_dog = other_box.create Dog
    other_dog.name = "Sundae"
    
    other_box.save
    
    other_box.dump
    
    dog.name = other_dog.name
    
    box.save
    
    box.dump
    
    true
  end
end

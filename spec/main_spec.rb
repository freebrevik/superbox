describe "Application 'SuperBox'" do
  
  # describe "This" do
  #   it "should" do
  #      SuperBox::Core.delete_all
  #     
  #      heaven = Heaven.create()
  #      heaven.desc = "Where Dogs go after they die."
  #     
  #      charlie = Dog.create(:name => "Charlie", :age => 6)
  #      itchy = Dog.create(:name => "Itchy", :age => 5)
  #      sparky = Dog.create(:name => "Sparky", :age => 2)
  #     
  #      heaven.addDogsObject(charlie)
  #      heaven.addDogsObject(itchy)
  #     
  #      SuperBox::Core.save
  #     
  #      SuperBox::Core.heavy_migrate do |data|
  #       
  #       
  #       
  #      end
  #     
  #     
  #   end
  # end
  describe "Filtering in SuperBox" do 
    
    before do
      #SuperBox::Core.dump
    end
    
    it "should create models" do
       SuperBox::Core.delete_all
      
       heaven = Heaven.create()
       heaven.desc = "Where Dogs go after they die."
      
       charlie = Dog.create(:name => "Charlie", :age => 6)
       itchy = Dog.create(:name => "Itchy", :age => 5)
       sparky = Dog.create(:name => "Sparky", :age => 2)
      
       heaven.addDogsObject(charlie)
       heaven.addDogsObject(itchy)
      
       SuperBox::Core.save.should == true
    end
    
    it "should retrieve all models" do
      SuperBox::Dogs.all.size.should.equal 3
    end
    
    it "should retrieve single model" do  
      SuperBox::Dogs.single.should.not.equal nil
    end
  
    it "should retrieve top two models" do  
      SuperBox::Dogs.top(2).size.should.equal 2
    end
    
    it "should sort by name ascending" do  
      SuperBox::Dogs.order_by(:name => :asc).single.name.should.equal "Charlie"
    end
    
    it "should sort by name descending" do  
      SuperBox::Dogs.order_by(:name => :desc).single.name.should.equal "Sparky"
    end
    
    it "should count models" do  
      SuperBox::Heaven.count.should.equal 1
    end
    
    it "should remove all entries of one model" do  
      SuperBox::Heaven.remove_all
      SuperBox::Heaven.count.should.equal 0
    end
    
    it "should still have one object of other model" do  
      SuperBox::Dogs.count.should.equal 1
    end
    
  end  
end
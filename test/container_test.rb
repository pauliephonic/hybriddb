

  class ContainerTest < Test::Unit::TestCase
    #test a hybrid object within another hybrid object
     def setup
        @num = rand(1_000_000_000)
        
        child = Child.new
        child.name = "Child_#{@num}"
        child.skill_range = 23..56
        child.toys = %w(ball top teddy)
        child.age = 12
        child.save
        
        @child_id = child.hybrid_id
        
        parent = Parent.new
        parent.name = "Parent_#{@num}"
        parent.child = child
        parent.save
        @parent_id = parent.hybrid_id
      end
      
      def test_embedded_exists
        new_parent = Parent.find @parent_id
        assert_equal new_parent.name, "Parent_#{@num}"
        child = new_parent.child
        assert_equal child.name, "Child_#{@num}"
        assert_equal child.toys, %w(ball top teddy)
        assert_equal child.skill_range, 23..56
        
      end
      
      def test_embedded_is_stubbed
        #check we get back an unloaded proxy before we acces it
        new_parent = Parent.find @parent_id
        assert_equal new_parent.name, "Parent_#{@num}"
        child = new_parent.child
        assert_equal 'NilClass', child.hybrid_proxy.class.name
        assert_equal child.name, "Child_#{@num}"
        assert_equal child.toys, %w(ball top teddy)
        assert_equal child.skill_range, 23..56
        assert_kind_of Child, child.hybrid_proxy
      end

      def test_complex
        num = rand(1_000_000_000)
        
        child_a = Child.new
        child_a.name = "Child_a_#{num}"
        child_a.age = 7
        
        child_b = Child.new
        child_b.name = "Child_b_#{num}"
        child_b.age = 13
        
        father_a = Parent.new
        father_a.name = "Father_#{num}"
        
        
        father_a.child = child_a
        child_a.father = father_a
        
        child_b.uncle = father_a
        father_a.nephews << child_b
        
        child_b.friends << child_a
        child_a.friends << child_b
        
        #save em all, from ground up, parent forcing child save should be tested seperately
        #this will fail if stack level too deep due to object dependencies
        child_a.save
        child_b.save
        father_a.save 
        
        @child_a_id = child_a.hybrid_id
        @child_b_id = child_b.hybrid_id
        @father_a_id = father_a.hybrid_id
        
        father_a = nil
        child_a = nil
        child_b = nil
        
        father_a = Parent.find(@father_a_id)
        #get child
        child_a = father_a.child
        assert_equal child_a.name, "Child_a_#{num}"
        
        child_b = child_a.friends.first
        assert_equal child_b.name, "Child_b_#{num}"
        assert_equal child_b.uncle.name, father_a.name
        
        child_b = father_a.nephews.first
        assert_equal child_b.name, "Child_b_#{num}"
        
      end
      
      def test_save_parent_saves_children
        num = rand(1_000_000_000)
        
        child = Child.new
        child.name = "Child_#{num}"
        child.age = 7
        
        
        father = Parent.new
        father.name = "Father_#{num}"       
        father.child = child
        child.father = father
        
        #save parent, should save child as it is connected
        father.save 
        
        @child_id = child.hybrid_id
        @father_id = father.hybrid_id
        
        father = nil
        child = nil
        
        father = Parent.find(@father_id)
        #get child
        child = father.child
        assert_equal child.name, "Child_#{num}"
        
      end
  end
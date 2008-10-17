class CollectionTest < Test::Unit::TestCase
	def setup
		@num = rand(1_000_000)
		Relationship.clear_all :iknowwhatimdoing
		@r = Relationship.new
		@r.name = "Jerry"
		@r.save
	end
	
	def test_append_hybrid_objects
		#append an array of objects
		c = Child.new
		c.name = 'baby cakes'
		@r.children << c
		
		assert_equal @r.children.length, 1
		
		c1 = Child.new
		c1.name = 'baby cakes 2'
		@r.children << c1
		
		assert_equal @r.children.length, 2
		
		@r.children.each{|child|
			@found1 = true if child.name == 'baby cakes'
			@found2 = true if child.name == 'baby cakes 2'
		}
		assert @found1, 'should have found first added item'
		assert @found2, 'should have found second added item'

	end
	
	def test_append_array
		#append an array of objects
		c = Child.new
		c.name = 'append cakes'
		
		c1 = Child.new
		c1.name = 'append cakes 2'
		@r.children << [c,c1]
		
		assert_equal @r.children.length, 2
		
		@r.children.each{|child|
			@found1 = true if child.name == 'append cakes'
			@found2 = true if child.name == 'append cakes 2'
		}
		assert @found1, 'should have found first added item from array'
		assert @found2, 'should have found second added item from array'
	end
	
	def test_append_non_hybrid
		#append a non hybrid object
		#check that the appended object has been hybridised
		v = Vanilla.new
		v.name = 'test'
		@r.children << v
		
		assert_equal @r.children.length, 1
		
		assert_equal @r.children.first.name, 'test'
	end
	
	def test_retrieval
		#append a non hybrid object
		#check that the appended object has been hybridised
		v = Vanilla.new
		v.name = 'test'
		@r.children << v
		c = Child.new
		c.name = 'retrieval'
		@r.children << c
		newid = @r.hybrid_id
		@r = nil
		new_object = Relationship.find(newid)
		assert_equal new_object.children.length, 2
		new_object.children.each{|child|
			@found1 = true if child.name == 'test' && child.class == Vanilla
			@found2 = true if child.name == 'retrieval' && child.class == Child
		}
		assert @found1, 'should have found added Vanilla object'
		assert @found2, 'should have found added Child object'

	end
	
	def test_delete_object_removes_reference
		#need to drop to sql for this
		c = Child.new
		c.name = 'delete'
		@r.children << c
		rid = @r.hybrid_id
		num_relations = HybridDB::Connection.get_data("select count(*) as length from hybrid_references where class_name = 'Relationship' and class_id = #{rid} and property = 'children';").first['length'].to_i
		assert_equal num_relations, 1
			
		@r.delete
		#check we have removed all references
		num_relations = HybridDB::Connection.get_data("select count(*) as length from hybrid_references where class_name = 'Relationship' and class_id = #{rid} and property = 'children';").first['length'].to_i
		assert_equal num_relations, 0, "should not be any references to an object after deletion"		
	end
	
	def test_append_saves_appended_object
		c = Child.new
		c.name = "appendsave_#{@num}"
		@r.children << c
		assert_not_nil c.hybrid_id, 'appended object should have a hybrid_id as it should be saved'
		cid = c.hybrid_id
		new_child = Child.find(cid)
		assert_equal new_child.name, "appendsave_#{@num}",'should be able to retrieve an object appended to a hybrid collection'
	end
	
	def test_remove_from_collection
		assert false, "Need to add a collection removal method D'oh!"
	end
end
	

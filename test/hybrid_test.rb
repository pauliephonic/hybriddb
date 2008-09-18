
class HybridTest < Test::Unit::TestCase
	def setup
		age = rand(1000)
		@vanilla = Vanilla.new
		@vanilla.name = "vanilla_#{age}"
		@vanilla.age = age	
		age = rand(1000)
		@inherited = Inherited.new
		@inherited.name = "inherited_#{age}"
		@inherited.age = age
	end
	#assert_equal
	
	def test_can_extend_vanilla
		assert_nothing_raised do
			@vanilla.extend HybridDB
		end
	end
	
	def test_extend_creates_hybrid_properties
		@vanilla.extend HybridDB
		#check that it has hybrid properties
		assert_nothing_raised do
			zero = @vanilla.hybrid_id
			zero = @vanilla.hybrid_version
		end
	end
	def test_extend_sets_hybrid_properties
		@vanilla.extend HybridDB
		#check that it has hybrid properties
		assert_equal @vanilla.hybrid_id, 0
		assert_equal @vanilla.hybrid_version, 0
	end
	
	def test_extend_keeps_vars
		age = @vanilla.age
		name = @vanilla.name
		@vanilla.extend HybridDB
		assert_equal @vanilla.age, age
		assert_equal @vanilla.name, name
	end
		
	def test_save_vanilla
		@vanilla.extend HybridDB
		assert @vanilla.save
		new_id = @vanilla.hybrid_id
		assert_not_nil(new_id)
	end
	
	def test_save_inherited
		assert @inherited.save
		new_id = @inherited.hybrid_id
		assert_not_nil(new_id)
	end
	
	def test_reopen
		age = @inherited.age  #store old values to check after reopen
		name = @inherited.name
		@inherited.save
		new_id = @inherited.hybrid_id
		#TODO change this test to use find(id)
		inherited2 = Inherited.find(new_id)
		assert_not_nil(inherited2)
		
		#check we don't have non zero hybrid properties
		assert_not_equal @inherited.hybrid_id, 0
		assert_not_equal @inherited.hybrid_version, 0
		
		#check has same properties
		assert_equal inherited2.age, age
		assert_equal inherited2.name, name
	end

	def test_find_first
		assert true
	end
	
	def test_size_updated
		@inherited.save #save to set size

		size = @inherited.hybrid_size
		#add 2 chars to name
		@inherited.name << "XX"
		@inherited.save
		#check size increased by 2
		assert_equal @inherited.hybrid_size, (size + 2)
		
		new_id = @inherited.hybrid_id
		inherited2 = Inherited.find(new_id)
		assert_equal inherited2.hybrid_size, (size + 2)
	end
	
	def test_conditions
		
	end
end

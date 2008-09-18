class IndexingTest < Test::Unit::TestCase
	
	def setup
		num = rand(1_000_000)
		@indexed = Indexed.new
		@indexed.name = "indexed_#{num}"
		@indexed.age = num
	end
	
	def test_index
		
	end
	
	def test_can_find_by_index
		# Indexed model has declaration 
		#
		#		indexes :name
		#we should be able to do finds on it
		name = @indexed.name
		age = @indexed.age
		@indexed.save
		new_item = Indexed.find(:first, :conditions => {:name => name})
		assert_not_nil new_item
		assert_equal new_item.age, age
		assert_equal new_item.name, name
	end
	
	def test_reindex
		
	end
	
	def test_index_delete
		
	end
	
	def test_find_on_unindexed
		#should raise an error
	end
end
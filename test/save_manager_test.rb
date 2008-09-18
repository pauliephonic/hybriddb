class SaveManagerTest < Test::Unit::TestCase
	def test_save_manager
		num = rand(1_000_000)
		assert_equal HybridSaveManager.queue_length, 0
		
		p = Parent.new
		p.name = "SaveTest_#{num}"
		HybridSaveManager.push p
		assert_equal HybridSaveManager.queue_length, 1
		
		q = Parent.new
		q.name = "SaveTest2_#{num}"
		HybridSaveManager.push q
		assert_equal HybridSaveManager.queue_length, 2
		
		new_parent = HybridSaveManager.pop
		assert_not_nil new_parent
		assert_equal new_parent.name, "SaveTest2_#{num}"
		assert_equal HybridSaveManager.queue_length, 1
		
		new_parent = HybridSaveManager.pop
		assert_not_nil new_parent
		assert_equal new_parent.name, "SaveTest_#{num}"
		assert_equal HybridSaveManager.queue_length, 0
	end
end



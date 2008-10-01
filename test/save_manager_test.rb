class SaveManagerTest < Test::Unit::TestCase
	def test_save_manager_with_objects
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
	#check that save manager additions in other threads don't interfere
	def test_save_manager_works_threaded
		puts "\nSpawning threads may take a few seconds....\n"
		threads = []
		
		10.times do |num|
			thread = Thread.new do
				assert_equal HybridSaveManager.queue_length, 0
				sleep 1
				HybridSaveManager.push "a#{num}"
				assert_equal HybridSaveManager.queue_length, 1
				sleep 1
				HybridSaveManager.push "b#{num}"
				assert_equal HybridSaveManager.queue_length, 2
				sleep 1
				HybridSaveManager.push "c#{num}"
				assert_equal HybridSaveManager.queue_length, 3
				sleep 1
				temp = HybridSaveManager.pop
				assert_equal HybridSaveManager.queue_length, 2
				sleep 1
				temp = HybridSaveManager.pop
				assert_equal HybridSaveManager.queue_length, 1
				sleep 1
				temp = HybridSaveManager.pop
				assert_equal HybridSaveManager.queue_length, 0
			end
			threads << thread
		end
		threads.each {|t| t.join}
	end
end



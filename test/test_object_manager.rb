  require 'test_helper'
class ObjectManagerTest < Test::Unit::TestCase
	#test that found objects update other objects linked
	
	def setup
		
	end
	
	def test_heavy
		flush_and_gc
		
		assert_equal num_hybrids, HybridObjectManager.length,  "Object Manager should have same number of objects as exists in ruby"
		
		Complex.clear_all :iknowwhatimdoing
		
		list = []
		
		1000.times{
			list << create_and_forget
		}
		#puts "\n\n\n" << HybridObjectManager.dump << "\n\n\n"
		cnt = num_hybrids
		assert_equal num_hybrids, HybridObjectManager.length, "Object Manager should have an object for each created"
		list = nil
		
		10.times{flush_and_gc}
		
		puts "#:#{num_hybrids}"
		assert_equal num_hybrids, HybridObjectManager.length, "Object Manager should have same number as exists in ruby space"
		assert num_hybrids < cnt, "Object Manager should have less items after GC"
	end
	
	def test_finds_of_same_object_get_same_id
		a = Parent.find(:first)
		b = Parent.find(:first)
		assert_equal a.object_id, b.object_id, "2 Hybrid objects found should refer to the same object with the same object_id"
	end
	
	def test_same_number_of_objects_in_manager
		cnt = num_hybrids
		assert_equal cnt, HybridObjectManager.length,  "Object Manager should have same number of objects as exists in ruby"
		
		#create and save some objects
		list = []
		17.times{|i|
			p = Complex.new
			p.name = "ptest #{i}"
			p.save
			list << p
			cnt +=1
		}
		assert_equal cnt, HybridObjectManager.length,  "Object Manager should have same number of objects added"
		
		parents = Parent.find(:all)
		cnt += parents.length
		
		assert_equal cnt, HybridObjectManager.length,  "Object Manager should have same number of objects added"
	end
		
	def test_saving_adds_to_manager
		assert false
	end
	
	def test_delete_object_removes_from_manager
		assert false
	end
	
	def test_clear_all_clears_manager_for_class
		assert false
	end
	
	#########################################################################################
	#		Helpers
	#
	
	def num_hybrids
		cnt = 0
		ObjectSpace.each_object(HybridObject){|o| cnt += 1 }
		cnt
	end
	
	def pick(an_array)
		an_array.sort_by{rand}.first
	end

	def update_random(a_complex)
		a_complex.age = rand(100)
		a_complex.name = pick(%w(Mr Mrs Ms Mdm)) + ' ' + pick(%w(Jones Smith McFlap Ohara Giggler Biggleswade Keitel))
		a_complex.tags = (1..rand(3)).map{pick %w(Interesting Silly Ruby Slartibartfast Happy Photos Blog)}.uniq
		a_complex.added_at = Time.now
	end
	
	def create_and_forget
		c = Complex.new
		update_random c
		c.save
		c
	end
	
	def flush_and_gc
		#try and trigger GC
		puts "fluchin...."
		crap = Array.new(1000){}
		1000.times do
			crap << Array.new(100){Object.new}
		end
		crap = nil
		GC.start
		del = Array.new(1000){Array.new(100){Object.new}}
		del = nil
		crap = nil
		GC.start
	end
end 

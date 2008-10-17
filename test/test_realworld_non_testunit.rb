	
		# this is a realworld test of adding finding modifying and saving objects that runs 
		# continually to check for memory leaks
		
		require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
		
		def flush_and_gc
			crap = []
			100.times do
				crap << Array.new(100){Object.new}
			end
			crap = nil
			GC.start
		end
		
		
		def get_list
			item_list = []
			Complex.find(:all).each{|c| 
				item_list << c.hybrid_id
			}
			item_list
		end
		
		item_list = get_list
		cnt = 0
		while 1 == 1
			cnt += 1
			#create an object
			1.times {
				p = Parent.new
				p.name = "RealTestParent#{rand(100)}"
				p.save
			}
			
			1.times {
				c = Complex.find(item_list.sort_by{rand}.first)
				c.age = c.age + 1
				c.save
			}
			
			flush_and_gc
			
			#output current objectmanager length
			puts "*" * HybridObjectManager.length
			puts HybridObjectManager.dump if cnt % 100 == 0
			#sleep 1
		end
		

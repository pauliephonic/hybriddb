	# TODO thread safe mutexes?????
	class HybridObjectManager
		#need 2 ways of getting at an object
		@@class_list = Hash.new{|h,k| h[k] = {}}
		#@@object_count = Hash.new{|h,k| h[k] = Hash.new(0)}
		@@objects = {}
		#add an object to the manager, make this failsafe by checking for same object?
		def self.add_object(an_object)
			klass = an_object.class.to_s
			hybrid_id = an_object.hybrid_id
			@@class_list[klass][hybrid_id] = an_object.object_id
			@@objects[an_object.object_id] = [klass, hybrid_id]
			ObjectSpace.define_finalizer(an_object, self.clear_up_finaliser)
		end
		
		def self.clear_up_finaliser
			lambda do |an_object_id| 
				object_class, object_hybrid_id = @@objects[an_object_id]
				@@class_list[object_class].delete object_hybrid_id
				@@class_list.delete(object_class) if @@class_list[object_class].keys.length == 0
				@@objects.delete an_object_id
			end
		end
		
		def self.find(klass, hybrid_id)
			ret = nil
			if @@class_list.has_key?(klass) && @@class_list[klass].has_key?(hybrid_id) && @@class_list[klass][hybrid_id]
				oid = @@class_list[klass][hybrid_id]
				begin
					ret = ObjectSpace._id2ref(oid)
				rescue RangeError
					ret = nil
				end
			end
			ret
		end
		
		def self.dump
			ret = "<HybridObjectManager: @@class_list = "
			@@class_list.each_key do |klass|
				ret << "<#{klass}: ["
				@@class_list[klass].each_key do |hybrid_id|
					ret << " #{hybrid_id} "
				end
				ret << "]>"
			end
			ret << " @@objects=["
			@@objects.each_key do |oid|
				ret << " #{oid} "
			end
			ret << "] >"
			ret
		end
		
		def self.length
			@@objects.length
		end
	end

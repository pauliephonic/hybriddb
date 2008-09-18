	class HybridCollection
		include Enumerable
		include HybridUtilities
		def initialize(owner_class, owner_id, property)
			@owner_class = owner_class
			@owner_id = owner_id
			@property = property
		end
		def reload
			sql="select hybrid_objects.* from 
					hybrid_objects
					inner join 
					
					(select 
						reference_class, 
						reference_id 
					from 
						hybrid_references 
					where 
						class_name = '#{@owner_class}' and 
						class_id = #{@owner_id} and 
						property = '#{@property}') rels
					on 
						hybrid_objects.class_name = rels.reference_class and
						hybrid_objects.id = rels.reference_id;"
			
			records = HybridDB::Connection.get_data sql
			@collection = get_objects_from_records(records)
		end
		def each
			collection.each{|object|
				yield object
			}
		end
		def length
			if @collection
				@collection.length
			else
				records = HybridDB::Connection.get_data "select count(*) as length from hybrid_references where class_name = '#{@owner_class}' and class_id = #{@owner_id} and property = '#{@property}';"
				records[0]['length'].to_i
			end
		end
		def <<(objects)
			Array(objects).each{|object|
				object.extend HybridDB unless object.respond_to? :hybrid_id #extend if not a hybrid
				object.save unless object.hybrid_saved?   #ensure object is saved
				
				#TODO check if already there

				#add to the hybrid references	
				HybridDB::Connection.execute "insert into hybrid_references (class_name, class_id, property, reference_class, reference_id) 	values('#{@owner_class}', #{@owner_id}, '#{@property}', '#{object.class.name}', #{object.hybrid_id});"
				#add if loaded
				@collection << object if @collection
			}
		end
		def first
			collection.first
		end
		def [](num)
			collection[num]
		end
		
		private
		
		def collection
			reload unless @collection
			@collection
		end
	end
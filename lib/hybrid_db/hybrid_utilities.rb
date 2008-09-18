module HybridUtilities
	def get_objects_from_records(records)
		results = []
		records.each {|record|
			data_as_yaml = record['data']
			ivar_hash = YAML.load data_as_yaml
			
			klass = record['class_name']
			hybrid_id = record['id'].to_i
			
			# if the object is in the manager, update it's attributes from the db
			
			if new_item = HybridObjectManager.find(klass, hybrid_id)
				#clear all old ivars
				new_item.instance_variables.each{|ivar| new_item.instance_variable_set(ivar, nil) unless HybridDB::IGNORE_IVARS.include? ivar}
			else
				new_item  = Object::const_get(record['class_name']).new
				new_item.instance_variable_set("@hybrid_id", record['id'].to_i) #set hybrid_id so hybrid_object_manager knows how to index
				HybridObjectManager.add_object(new_item)
			end
					
			#set ivars from hash
			ivar_hash.each_key do |key|
				new_item.instance_variable_set(key, ivar_hash[key])
			end
			
			#update hybrid related info from db
			new_item.instance_variable_set("@hybrid_version", record['version'].to_i)
			new_item.instance_variable_set("@hybrid_size", record['size'].to_i)
			new_item.instance_variable_set("@hybrid_saved", true)

			results << new_item
		}
		results
	end
	def extract_options(args)
		if args.last.class == Hash
			options = args.pop
		else
			options = {}
		end
		[args,options]
	end
end
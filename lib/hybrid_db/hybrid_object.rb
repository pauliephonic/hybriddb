	class HybridObject
		class << self
			def indexes(*args)
				# set the following properties as indexed, ie they will be added to 
				# indexes and indexes will be used to find them
				items = Array(args)
				items.map!{|i| i.to_s.intern} #TODO test string and symbol
				@indexed_items ||= []
				@indexed_items += items
			end
			def hybrid_indexes
				@indexed_items || []
			end
			
			#eg collection :child, :manager
			def has_many(*args)
				items = Array(args)
				items.map!{|i| i.to_s.intern}
				items.each{|item|
					#define instance methods for accessing the HybridCollection obejct
					define_method item do
						unless @hybrid_id && @hybrrid_id != 0
							collection = nil #return nil if no @hybrid_id
						else
							collection = instance_variable_get("@#{item}")
							unless collection
								collection = HybridCollection.new(self.class.name, @hybrid_id, item)
								instance_variable_set("@#{item}", collection)
							end							
						end
						collection
					end
				}
			end
	 	end
		
		include HybridDB
	end
#<
# Copyright (c) 2008 Paul McConnon
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#>



	require 'rubygems'
	require 'yaml'
	
	$:.unshift(File.dirname(__FILE__)) unless $:.include?( File.dirname(__FILE__) ) || $:.include?(File.expand_path(File.dirname(__FILE__)))
	
	require 'hybrid_db/hybrid_utilities'
	
	module HybridDB
		IGNORE_IVARS = ['@hybrid_id', '@hybrid_version', '@hybrid_saved', '@hybrid_size']
		attr_accessor :connection
		module ClassMethods; end
		def self.included(klass)
			klass.extend(ClassMethods)
		end
		def save
			#2 stage save, placeholder, then data, this enables stubbing unsaved objects
			save_placeholder unless @hybrid_id
			save_contents
			#save the contents of any hybrid objects that we saved placeholders for
			while to_save = HybridSaveManager.pop
				to_save.save_contents
			end
			true
		end
		def save_placeholder
			@hybrid_id = Connection.insert_and_return_id(my_class_name, '')
			@hybrid_version = 0
			#place into manager
			HybridObjectManager.add_object(self)
			true
		end
		def save_contents
			data = marshalled_ivars
			@hybrid_size = data.length
			Connection.update_data(my_class_name, @hybrid_id, data, @hybrid_size)
			#sql = "update hybrid_objects set data = '#{escape(data)}', version = version + 1, size = #{@hybrid_size} where class_name = '#{my_class_name}' and id = #{@hybrid_id}"
			#Connection.execute sql
			@hybrid_version += 1
			recreate_indexes
			@hybrid_saved = true
		end
		def delete
			Connection.delete_object(my_class_name, @hybrid_id)
			HybridObjectManager.clear_up_finaliser.call(self.object_id)
			@hybrid_id = nil
			@hybrid_saved = false
			@hybrid_version = 0
			true
		end
		def marshalled_ivars
			h = {}
			self.instance_variables.each do |ivar|
				unless IGNORE_IVARS.include?(ivar)
					val = self.instance_variable_get(ivar)
					h[ivar] = val unless val.class == HybridCollection
				end
			end
			YAML.dump(h)
		end
		
		def recreate_indexes
			# check in case we extended an object and its class doesn't support the hybrid_indexes property
			if self.class.respond_to? :hybrid_indexes 
				indexed_items = self.class.hybrid_indexes
			else
				indexed_items = []
			end
		
			if indexed_items.length > 0 
				Connection.execute("delete from hybrid_indexes where class_name = '#{my_class_name}' and id = #{@hybrid_id}")
				self.instance_variables.each do |ivar|
					property_name = ivar.gsub('@','')
					if indexed_items.include?(property_name.intern)
						property_value = YAML.dump(self.instance_variable_get(ivar))	
						Connection.execute("insert into hybrid_indexes (class_name, property_name, property_value, id) values('#{my_class_name}', '#{property_name}','#{property_value}', #{@hybrid_id})")
					end
				end
			end		
		end
		
		def hybrid_id
			@hybrid_id || 0
		end
		def hybrid_version
			@hybrid_version || 0
		end
		def hybrid_size
			@hybrid_size || 0
		end
		def hybrid_saved?
			@hybrid_saved || false
		end
		def to_yaml(opts = {})
			self.save_placeholder unless @hybrid_id #save a stub if not yet allocated a hybrid_id
			#mark contents for save if required 
			HybridSaveManager.push(self) unless @hybrid_saved
			stub = HybridStubBlank.new(self.class.name, @hybrid_id) #create a new blank hybridstub and call it's to_yaml
			stub.to_yaml(opts) #save data now that we have got yaml out?
		end
	
		####################################################
		#	 Helpers
	
	
		def my_class_name
			self.class.to_s
		end
					
		module ClassMethods
			include HybridUtilities
			def find_from_ids(nums)
				nums = Array(nums)
				records = Connection.get_data("Select * from hybrid_objects where class_name = '#{self.name}' and id in (#{nums.join(',')})")
				objects = get_objects_from_records(records)
				if nums.length == 1
					objects.first
				else
					objects
				end
			end
			def find(*args)
				args, options = extract_options(args)
				case args.first
					when :first then find_initial(options)
					when :all then find_every(options)
					else			 find_from_ids(args)
				end
			end
			def find_initial(options)
			 	options.update(:limit => 1)
			 	find_every(options).first
			end
			def find_every(options)
				sql = construct_sql(options)
				records = Connection.get_data(sql)
				get_objects_from_records (records)
			end
			def construct_sql(options)
				conditions = options[:conditions] || {}
				sql = construct_index_sql(conditions)
				if options[:limit]
					sql << " limit #{options[:limit]}" #this is mysql specific?
				end
				sql
			end
			def construct_index_sql(conditions)
				index_clauses =[]
				conditions.each_key{|field|
					raise "Index (#{field}) not found, have you used the 'indexes' clause, you big silly?" unless self.hybrid_indexes.include?(field)
					property_value = YAML.dump(conditions[field])
					index_clauses << "(property_value = '#{property_value}' and property_name = '#{field}')"
				}
				index_where =''
				if index_clauses.length > 0 
					index_where = " and id in (select id from hybrid_indexes where class_name = '#{self.name}' and (#{index_clauses.join(' and ')}) )"
				end
				"select * from hybrid_objects where class_name ='#{self.name}' #{index_where}"
			end
	
			def total_size
				#TODO recs are coming back as hashes
				Connection.get_data("Select sum(size) as total_size from hybrid_objects where class_name = '#{self.name}'").first['total_size'].to_i
			end
			
			def clear_all(affirm = nil)
				# TODO need to remove any refs on objectmanager
				unless affirm && affirm.to_s.intern == :iknowwhatimdoing
					raise "clear_all requires that the symbol :iknowwhatimdoing is passed to ensure against accidental deletes"
				else
					# delete all indexes for this class
					Connection.execute("delete from hybrid_indexes where class_name = '#{self.name}'")
					# delete data all data for this class
					Connection.execute("delete from hybrid_objects where class_name = '#{self.name}'")
					# delete relationships
					Connection.execute("delete from hybrid_references where class_name = '#{self.name}' or reference_class = '#{self.name}'")
					
					# TODO reset all object in the OM
				end
			end
	 end
	
	 class Connection
			def self.set_adapter(new_conn)
				@@adapter = new_conn
			end
			def self.execute(sql)
				@@adapter.execute(sql)
			end
			def self.get_data(sql)
				@@adapter.get_data(sql)
			end
			def self.insert_and_return_id(class_name, data)
				@@adapter.insert_and_return_id(class_name, data)
			end
			def self.delete_object(class_name, id)
				@@adapter.delete_object(class_name, id)
			end
			def self.update_data(klass, hybrid_id, data, size)
				@@adapter.update_data klass, hybrid_id, data, size
			end
		end
	end #module hybrid_db
	
	require 'hybrid_db/blank_object'
	require 'hybrid_db/hybrid_save_manager'
	require 'hybrid_db/hybrid_stub'
	require 'hybrid_db/hybrid_stub_blank'
	require 'hybrid_db/hybrid_object'
	require 'hybrid_db/hybrid_collection'
	require 'hybrid_db/adapters'
	require 'hybrid_db/hybrid_object_manager'
	

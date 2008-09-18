	class HybridStub < BlankObject
		#must have a @hybrid_id instance var to use for find
		def initialize(hybrid_class_name = nil, hybrid_id = nil)
			@hybrid_id = hybrid_id
			@hybrid_class_name = hybrid_class_name
			@hybrid_proxy = nil
			@hybrid_loading = false
			# TODO should we check here for the object in the manager and preset our proxy?
		end
	
		def hybrid_proxy
			@hybrid_proxy 
		end
	
		def load_proxy
			@hybrid_loading = true
			#puts "loading proxy #{@hybrid_class_name} #{@hybrid_id}"
			unless @hybrid_id && @hybrid_class_name
				raise NoMethodError, "Hybrid object not loaded, hybrid_id or hybrid_class_name is missing, supplied was Class:#{@hybrid_class_name} and id: #{@hybrid_id}"
			else
				# check if we have the object in the object manager, if so set our proxy to that
				unless @hybrid_proxy = HybridObjectManager.find(@hybrid_class_name, @hybrid_id)
					# create a class of kind @hybrid_class_name
					klass = Object::const_get(@hybrid_class_name)
					#call its find with @hybrid_id
					@hybrid_proxy = klass.find(@hybrid_id)
				end
			end
			@hybrid_loading = nil
		end
		
		#need to alias repond to
		alias :old_respond_to? :respond_to?
		
		def respond_to?(method)
			if (method.to_s =~ /yaml/) || @hybrid_loading
				old_respond_to?(method)
			else
				if @hybrid_proxy
					@hybrid_proxy.respond_to?(method)
				else
					#load
					self.load_proxy
					@hybrid_proxy.respond_to?(method)
				end
			end
		end
		
		def method_missing(method, *args, &block)
			#puts "method missing called #{method.to_s}"
			if @hybrid_proxy
				if method.to_s == 'inspect'
					"#<Stub #{@hybrid_class_name}:#{@hybrid_id} *Loaded*>"
				else
					#puts "sending #{method.to_s} to proxy"	 
					@hybrid_proxy.__send__(method, *args, &block)
				end
			else
				if @hybrid_loading
					raise NoMethodError, "not loaded"
				else
					if method.to_s == 'inspect'
						"#<Stub #{@hybrid_class_name}:#{@hybrid_id} *Unloaded*>"
					else
						#load
						self.load_proxy
						@hybrid_proxy.__send__(method, *args, &block)
					end
				end
			end
		 end
			
		def to_yaml(opts = {})
			#self.save_placeholder unless @hybrid_id #save a stub if not yet allocated a hybrid_id
			stub = HybridStubBlank.new(@hybrid_class_name, @hybrid_id) #create a new blank hybridstub and call it's to_yaml
			stub.to_yaml(opts)
		end
	
	end


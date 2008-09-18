	class HybridStubBlank
		def initialize(hybrid_class_name = nil, hybrid_id = nil)
			@hybrid_id = hybrid_id
			@hybrid_class_name = hybrid_class_name
		end
		def taguri
			 "tag:ruby.yaml.org,2002:object:HybridStub"
		end
	end
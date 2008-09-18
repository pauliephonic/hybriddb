class Indexed < HybridObject
	indexes :name, :age #cause this attribute to be indexed
	attr_accessor :name, :age
	
	def initialize
		@added_at = Time.now
	end
end
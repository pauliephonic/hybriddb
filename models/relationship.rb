class Relationship < HybridObject
	indexes :name
	has_many :children, :managers
	attr_accessor :name, :age
	
	def initialize
		@added_at = Time.now
	end
end
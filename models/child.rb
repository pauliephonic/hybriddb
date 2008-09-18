
	class Child < HybridObject
		attr_accessor :name, :age, :toys, :skill_range, :friends, :father, :mother, :uncle
		def initialize
			@friends =[]
		end
	end
    
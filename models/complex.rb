class Book
	attr_accessor :title, :author
end

class Complex < HybridObject
	indexes :name #cause this to be indexed
	attr_accessor :name, :age, :num_range, :tags, :books, :added_at, :config
	
	def initialize
		
	end
end
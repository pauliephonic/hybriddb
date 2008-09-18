
class ComplexTest < Test::Unit::TestCase
	def setup
		
	end
	def test_save_and_reopen
		Complex.clear_all(:iknowwhatimdoing)
		books = []
		%w(george paul ringo john).each {|name|
			book = Book.new
			book.author = name
			book.title = "A nice book by #{name}"
			books << book
		}
		name, age, num_range, tags, added_at, config	= 'paul',123, 12..56, %w(great programmer), Time.now, {:background => 'light', :theme => 'pants'}
		complex = Complex.new
		complex.name = name
		complex.age = age
		complex.num_range = num_range
		complex.tags = tags
		complex.books = books
		complex.added_at = added_at
		complex.config = config
		complex.save
		complex = nil
		
		complex = Complex.find(:first, :conditions => {:name => 'paul'})
		assert_equal complex.name , name
		assert_equal complex.age , age
		assert_equal complex.num_range , num_range
		assert_equal complex.tags , tags
		(0..books.length-1).each{|num|
			assert_equal complex.books[num].author, books[num].author
			assert_equal complex.books[num].title, books[num].title
		}
		
		assert_equal complex.added_at , added_at
		assert_equal complex.config , config
	end
	
end



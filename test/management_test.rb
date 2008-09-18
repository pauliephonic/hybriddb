class ManagementTest < Test::Unit::TestCase
	
	def setup
		
	end
	
	def test_clear_all
		#test that we need :iknowwhatimdoing, to be passed	
		 assert_raise RuntimeError do
		    Inherited.clear_all
		 end
		 
		 assert_nothing_raised do
		    Inherited.clear_all(:iknowwhatimdoing)
		 end
		 #check we have no records
		 recs = Inherited.find(:all)
		 assert_equal recs.length, 0
		 
		 #check that our total size is 0
		 assert_equal Inherited.total_size, 0
	end

	def test_class_total_size
		old_size = Inherited.total_size
		inherited = Inherited.new
		inherited.name = "Paul McConnon"
		inherited.save
		rec_size = inherited.hybrid_size
		#check that the overall size has been updated by the size of the last record added
		assert_equal old_size + rec_size, Inherited.total_size
	end
	
	def test_find_on_unindexed
		#should raise an error
		
	end
	
	def test_create_tables
		
	end
end
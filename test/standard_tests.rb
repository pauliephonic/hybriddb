
	#all tests except object manager test
	require 'test_helper'

	Dir['*_test.rb'].each {|test_case| 
		require test_case 
	}

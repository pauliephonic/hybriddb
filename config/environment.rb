
		require File.dirname(__FILE__) + '/../lib/hybriddb'

		#load db settings
		env = 'localhost'
		HybridDB::Connection.set_adapter(MySQLAdapter.new({:host=> env, :user => 'sqllogin', :password => 'sqllogin', :database => 'hybriddb' }))

		#include all models in model folder
		Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|model| 
			require model
		}

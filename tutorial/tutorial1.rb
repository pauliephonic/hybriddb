	#tutorial1 - introduces hybriddb
	require '../lib/hybriddb'
	#Connect to the specified database and create the (minimal set of) tables required for operation if not present
	HybridDB::Connection.set_adapter(MySQLAdapter.new({:host=> 'localhost', :user => 'sqluser', :password => 'password', :database => 'hybriddb' }))
	
	#create a model by inheriting from HybridObject
	class BlogPost < HybridObject 
		attr_accessor :title, :content, :viewable_range
	end

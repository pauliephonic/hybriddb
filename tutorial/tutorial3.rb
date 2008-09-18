	#tutorial 3
	#Indexing
	require '../lib/hybriddb'
	HybridDB::Connection.set_adapter(MySQLAdapter.new({:host=> 'myservername', :user => 'sqluser', :password => 'password', :database => 'hybriddb' }))

	#declare a model and index a property
	class User < HybridObject 
		indexes :name
		attr_accessor :name, :department, :is_admin
	end
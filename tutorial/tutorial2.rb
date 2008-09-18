	# Tutorial2 
	# Hybrid Objects within Hybrid Objects
	require '../lib/hybriddb'
	HybridDB::Connection.set_adapter(MySQLAdapter.new({:host=> 'myservername', :user => 'sqluser', :password => 'password', :database => 'hybriddb' }))

		#add 2 hybrid models
	class Parent < HybridObject 
		attr_accessor :name, :age, :child
	end

	class Child < HybridObject 
		attr_accessor :name, :age, :parent
	end
	
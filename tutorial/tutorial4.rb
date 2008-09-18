	#tutorial 4
	#Collections
	require '../lib/hybriddb'
	HybridDB::Connection.set_adapter(MySQLAdapter.new({:host=> 'myservername', :user => 'sqluser', :password => 'password', :database => 'hybriddb' }))

	#declare some models
	class BlogPost < HybridObject 
		indexes :title
		has_many :comments
		attr_accessor :title, :content
	end
	
	class BlogComment < HybridObject
		attr_accessor :author, :content
	end
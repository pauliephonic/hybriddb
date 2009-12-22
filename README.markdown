HybridDB is a prototype hybrid Relational / Object database for Ruby.

It uses a relational database as the object store, but doesn’t need a database schema to work.

While it uses an SQL server (initially MySQL) for data storage, no SQL is required to use it. You just create objects and tell them to ‘Save’, HybridDB takes care of storing them.

It has the benefits of a SQL server like indexing, easy backup and restore along with the benefits of an object database like no need for a schema.

It works by storing all instance variable for your objects to the database and recording indexing and relational info for them if required.

When you need the object again, it is recreated, and it’s instance variables are restored to the condition they were in when the object was saved.

Objects can be found using simple activerecord like syntax e.g MyObject.find(12345) or MyObject.find(:first, :conditions = {:name => ‘Paul’})

To make your ordinary Ruby objects savable using HybridDB simply inherit from HybridObject (or a descendant of HybridObject)

Note: Objects added to collections do not need to be Hybrid Objects, they will be extended if required.
Example

We declare the following classes. We DO NOT create any tables in the database.

	class BlogPost < HybridObject 
		indexes :title 
		has_many :comments
		attr_accessor :title, :content, :pingbacks
		def initialize
		    @pingbacks =[]
		end
	end
	class BlogComment < HybridObject
		indexes :author
		attr_accessor :author, :content
	end
	class PingBack
		#not a hybrid object
		attr_accessor :address, :ping_time
	end

	b=BlogPost.new
	b.title = "Post One" 
	b.content = "Blah blah blah" 
	pb = PingBack.new
	pb.address="www.blogger.com" 
	pb.ping_time = Time.now
	p.pingbacks << pb   
	b.save
	comment1 = BlogComment.new
	comment1.author="Playa1" 
	comment1.content = "First Post!" 
	b.comments << comment1

We have saved a blog post, added a pingback and appended a comment to it’s comments collection. We can now do:

	post = BlogPost.find(:first, :conditions => {:title => 'Post One'})
	post.content
	=> "Blah blah blah" 
	post.pingbacks
	=> [#]

Note : The PingBack, while saved, cannot be accessed on it’s own via find, as it is not a hybrid object.

	post.comments.first.content
	=> "First Post!"

Or find the comment on it’s own.

	Comment.find(:first, :conditions => {:author => "Playa1"}).content
	=> "First Post!"

No SQL, no schema, just add classes that inherit from HybridObject and you’re good to go!

See the Getting Started tutorial for more in-depth examples.
Database Structure

The HybridDB database structure is created for you if it is not present, and consists of only 3 tables.

hybrid_objects

This table stores the actual data for your object, along with a unique id, your objects class name, it’s size, version and when it was last updated.

hybrid_indexes

This table contains indexes for indexed properties of your objects, along with a arefernce to the acual object indexed.

hybrid_references

This table manages collections of hybrid objects within other hybrid objects. It allows us to append new objects to a collection in our object without having to resave the parent object.

I note these for reference only, you never access them directly.

Note : HybridDb is a very early prototype and is not recommended for using in critical applications. I’ve released it so that I can get feedback on what works and what doesn’t.

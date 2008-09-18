	
	#must respond to an execute, get_data etc
	class MySQLAdapter
		require "mysql"
		def initialize(options)
			@database = options[:database]
			@user = options[:user]
			@password = options[:password]
			@host = options[:host]
			@connected = false
			connect
		end
		def connect
			begin
				@dbh = Mysql.real_connect(@host, @user, @password, @database, nil, nil, Mysql::CLIENT_MULTI_STATEMENTS)
				create_tables_if_required
				@connected = true
			rescue Mysql::Error => e
				puts "Error code: #{e.errno}"
				puts "Error message: #{e.error}"
				puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
			end
		end
		def create_tables_if_required
			statements = File.read(File.join(File.dirname(__FILE__),"/create_db_mysql.sql")).split(';').map{|s| s + ';'}.reject{|s| s.length < 3}
			statements.each{|sql| execute sql}
		end
		def disconnect
			@dbh.close
			@connected = false
		end		
		def execute(sql)
			#@dbh.query_with_result = false
			@dbh.query sql
		end
		def get_data(sql)
			@dbh.query_with_result = true
			res = @dbh.query sql
			ret_hash = []
			while row = res.fetch_hash do
				ret_hash << row
			end
			res.free
			ret_hash
		end	
		def insert_and_return_id(class_name, data)
			#TODO use @dbh.insert_id in a single statement
			@dbh.autocommit(false)
			execute "insert into hybrid_objects (class_name, data, version, size) values('#{class_name}','#{data}',1, #{data.length});"
			res = get_data("SELECT LAST_INSERT_ID() as new_id;")
			@dbh.commit
			@dbh.autocommit(true)
			res
		end
		
		def delete_object(class_name, id)
			#puts "executing \n\n  insert into #{class_name}(data, version) values('#{data}',1); SELECT LAST_INSERT_ID() as new_id;"
			# delete object and any indexes or references to or from it
			execute "delete from hybrid_objects where class_name = '#{class_name}' and id = #{id};"
			execute "delete from hybrid_indexes where class_name = '#{class_name}' and id = #{id};"
			execute "delete from hybrid_references where (class_name = '#{class_name}' and class_id = #{id}) or  (reference_class = '#{class_name}' and reference_id = #{id});"
		end
		
		def create_tables
			raise "Not implemented"
 		end
	end

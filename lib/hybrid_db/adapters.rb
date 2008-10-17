	
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
				false
			end
		end
		
		def create_tables_if_required
			statements = File.read(File.join(File.dirname(__FILE__),"/create_db_mysql.sql")).split(';').map{|s| s + ';'}.reject{|s| s.length < 3}
			execute_multiple_statements(statements)#.each{|sql| execute sql}
		end
		
		def disconnect
			@dbh.close
			@connected = false
		end		
		def execute(sql)
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
		def each_row(sql)
			@dbh.query_with_result = true
			res = @dbh.query sql
			while row = res.fetch_hash do
				yield row
			end
			res.free
		end
		def insert_and_return_id(class_name, data)
			#TODO use @dbh.insert_id in a single statement
			@dbh.autocommit(false)
			execute "insert into hybrid_objects (class_name, data, version, size) values('#{class_name}','#{data}',1, #{data.length});"
			res = get_data("SELECT LAST_INSERT_ID() as new_id;")
			@dbh.commit
			@dbh.autocommit(true)
			res.first['new_id'].to_i
		end
		
		def create_statement(hybrid_id, class_name, data)
			arr = []
			arr << "delete from hybrid_objects where id = #{hybrid_id};"
			arr << "insert into hybrid_objects (id, class_name, data, version, size) values(#{hybrid_id}, '#{class_name}','#{data}',1, #{data.length});"
		end
		
		def delete_object(class_name, id) # delete object and any indexes or references to or from it
			execute "delete from hybrid_objects where class_name = '#{class_name}' and id = #{id};"
			execute "delete from hybrid_indexes where class_name = '#{class_name}' and id = #{id};"
			execute "delete from hybrid_references where (class_name = '#{class_name}' and class_id = #{id}) or  (reference_class = '#{class_name}' and reference_id = #{id});"
		end
		
		def delete_object_statements(class_name, id)
			arr = []
			arr << "delete from hybrid_objects where class_name = '#{class_name}' and id = #{id};"
			arr << "delete from hybrid_indexes where class_name = '#{class_name}' and id = #{id};"
			arr << "delete from hybrid_references where (class_name = '#{class_name}' and class_id = #{id}) or  (reference_class = '#{class_name}' and reference_id = #{id});"
			arr
		end
		
		def update_data(klass, hybrid_id, data, size)
			execute update_statement(klass, hybrid_id, data, size)
		end 
		
		def update_statement(klass, hybrid_id, data, size)
			"update hybrid_objects set data = '#{escape(data)}', version = version + 1, size = #{size}, updated_at = now() where class_name = '#{klass}' and id = #{hybrid_id}"
		end
		def escape(string)
			Mysql.escape_string(string)
		end
		def execute_multiple_statements(statement_list)
			@dbh.autocommit(false)
			statement_list.each{|sql| execute sql }
			@dbh.commit
			@dbh.autocommit(true)
		end
		def get_next_hybrid_id
			@dbh.autocommit(false)
			execute "update hybrid_ids set next_id = next_id + 1;"
			res = get_data("select next_id from hybrid_ids;")
			@dbh.commit
			@dbh.autocommit(true)
			res.first['next_id'].to_i
		end
	end

require 'singleton'
class HybridSaveManager
	include Singleton
	@@mutex = Mutex.new
	@@save_queue =[]
	@@statements = []
	@@create_ids = []
	
	def self.push(hybrid_object)
		@@mutex.synchronize do
	 		@@save_queue << hybrid_object unless @@save_queue.include? hybrid_object
		end
	end
	def self.pop
		@@mutex.synchronize do
			@@save_queue.pop	
		end
	end
	def self.queue_length
		@@mutex.synchronize do
	 		@@save_queue.length
		end
	end
	
	# new statement method
	def self.begin_transaction
		# warn if not empty?
		@@save_queue = []
		@@statements = []
		@@create_ids = []
	end
	
	def self.add_statements(statements)
		statements = Array(statements)
		@@mutex.synchronize do
			statements.each{|sql|
				@@statements << sql
			}
		end
	end
	
	def self.add_create_statement(hybrid_id, statements)
		statements = Array(statements)
		@@mutex.synchronize do
			@@create_ids << hybrid_id
			statements.each{|sql|
				@@statements << sql
			}
		end
	end
	
	def self.contains_create_for?(hybrid_id)
		@@mutex.synchronize do
			@@create_ids.include? hybrid_id
		end
	end

	def self.commit_transaction
		@@mutex.synchronize do
			HybridDB::Connection.execute_multiple_statements(@@statements)
	 		@@statements = []
	 		@@create_ids = []
		end
	end
end

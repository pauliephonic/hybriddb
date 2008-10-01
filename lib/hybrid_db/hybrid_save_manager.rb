# TODO Mutexes may be unnecessary with hash based on thread
require 'singleton'
class HybridSaveManager
	include Singleton
	@@mutex = Mutex.new
	#need a save queue per thread
	@@save_queue = Hash.new{|h, k| h[k] = Array.new }

	@@statements = Hash.new([])
	@@create_ids = Hash.new([])
	@@in_transaction = Hash.new(false)
	
	def self.push(hybrid_object)
		@@mutex.synchronize do
	 		@@save_queue[Thread.current.object_id] << hybrid_object unless @@save_queue[Thread.current.object_id].include? hybrid_object
		end
	end
	def self.pop
		@@mutex.synchronize do
			@@save_queue[Thread.current.object_id].pop
		end
	end
	def self.queue_length
		@@mutex.synchronize do
	 		@@save_queue[Thread.current.object_id].length
		end
	end
	
	# new statement method
	def self.begin_transaction
		# TODO warn if not empty?
		@@mutex.synchronize do
			@@in_transaction[Thread.current.object_id] = true
			@@save_queue[Thread.current.object_id] = []
			@@statements[Thread.current.object_id] = []
			@@create_ids[Thread.current.object_id] = []
		end
	end
	
	def self.add_statements(statements)
		statements = Array(statements)
		@@mutex.synchronize do
			statements.each{|sql|
				@@statements[Thread.current.object_id] << sql
			}
		end
	end
	
	def self.add_create_statement(hybrid_id, statements)
		statements = Array(statements)
		@@mutex.synchronize do
			@@create_ids[Thread.current.object_id] << hybrid_id
			statements.each{|sql|
				@@statements[Thread.current.object_id] << sql
			}
		end
	end
	
	def self.contains_create_for?(hybrid_id)
		@@mutex.synchronize do
			@@create_ids[Thread.current.object_id].include? hybrid_id
		end
	end

	def self.commit_transaction
		@@mutex.synchronize do
			# TODO how will connection adapter work with threads, does it need it's own mutex?
			HybridDB::Connection.execute_multiple_statements(@@statements[Thread.current.object_id])
	 		@@statements[Thread.current.object_id] = []
	 		@@create_ids[Thread.current.object_id] = []
	 		@@in_transaction[Thread.current.object_id] = false
		end
	end
end

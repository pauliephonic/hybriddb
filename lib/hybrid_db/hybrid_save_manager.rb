require 'singleton'
class HybridSaveManager
	include Singleton
	@@mutex = Mutex.new
	@@save_queue =[]
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
end
class Inherited < HybridObject
  attr_accessor :name, :age, :added_at
  def initialize
  	@added_at = Time.now
  end
end
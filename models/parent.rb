
    class Parent < HybridObject
      attr_accessor :name, :child, :added_at, :spouse, :nephews
      def initialize
        @added_at = Time.now
        @nephews = []
      end
    end
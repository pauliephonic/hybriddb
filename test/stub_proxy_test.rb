    
    
    class StubProxyTest < Test::Unit::TestCase
      def setup
        an_object = Complex.find(:first)
        @id = an_object.hybrid_id
        #create a new proxy of Inherited
        @stub = HybridStub.new(Complex.name, @id)
        @age = an_object.age
        @name= an_object.name
        @num_range= an_object.num_range
        @added_at= an_object.added_at
      end
      
      def test_respond_to_loads_proxy
        #check we start with blank slate
        assert_equal 'NilClass', @stub.hybrid_proxy.class.name
        #call respond_to and see if it loads proxy and that the proxy answers our calls
        assert @stub.respond_to?(:age)
        assert @stub.respond_to?(:age=)
        assert @stub.respond_to?(:name)
        assert @stub.respond_to?(:name=)
        assert @stub.respond_to?(:num_range)
        assert !(@stub.respond_to?(:ridiculous))
        #check that the object acts like its proxy class now
        assert_kind_of Complex, @stub.hybrid_proxy
      end
      
      def test_method_access_loads_proxy
        assert_equal 'NilClass', @stub.hybrid_proxy.class.name
        assert_equal @stub.age, @age
        assert_equal @stub.name, @name
        assert_equal @stub.num_range, @num_range
        assert_equal @stub.added_at, @added_at
        assert_kind_of Complex, @stub.hybrid_proxy
        #check we fail on missing methods
        assert_raise NoMethodError do
          @stub.gothewholehogbebiggerthangod
        end

      end
    end
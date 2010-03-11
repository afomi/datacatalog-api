require File.expand_path(File.dirname(__FILE__) + '/../test_resource_helper')

class TryUnitTest < Test::Unit::TestCase

  context "Try" do
    
    context "to_i" do
      test %("123") do
        assert_equal 123, Try.to_i("123")
      end

      test %("123.45") do
        assert_equal "123.45", Try.to_i("123.45")
      end
      
      test %(123) do
        assert_equal 123, Try.to_i(123)
      end

      test %(123.45) do
        assert_equal 123.45, Try.to_i(123.45)
      end
      
      test %(abc) do
        assert_equal "abc", Try.to_i("abc")
      end
    end

    context "to_i_or_f" do
      test %("123") do
        assert_equal 123, Try.to_i_or_f("123")
      end

      test %("123.45") do
        assert_equal 123.45, Try.to_i_or_f("123.45")
      end
      
      test %(123) do
        assert_equal 123, Try.to_i_or_f(123)
      end

      test %(123.45) do
        assert_equal 123.45, Try.to_i_or_f(123.45)
      end

      test %(abc) do
        assert_equal "abc", Try.to_i("abc")
      end
    end

    context "to_i?" do
      test %("123") do
        assert_equal true, Try.to_i?("123")
      end

      test %("123.45") do
        assert_equal false, Try.to_i?("123.45")
      end
      
      test %(123) do
        assert_equal true, Try.to_i?(123)
      end

      test %(123.45) do
        assert_equal false, Try.to_i?(123.45)
      end
      
      test %(abc) do
        assert_equal false, Try.to_i?("abc")
      end
    end

    context "to_f?" do
      test %("123") do
        assert_equal true, Try.to_f?("123")
      end

      test %("123.45") do
        assert_equal true, Try.to_f?("123.45")
      end
      
      test %(123) do
        assert_equal true, Try.to_f?(123)
      end

      test %(123.45) do
        assert_equal true, Try.to_f?(123.45)
      end
      
      test %(abc) do
        assert_equal false, Try.to_f?("abc")
      end
    end
    
  end

end
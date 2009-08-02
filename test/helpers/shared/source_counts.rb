class RequestTestCase

  shared "incremented source count" do
    test "should increment source count" do
      assert_equal Source.count, @source_count + 1
    end
  end
  
  shared "unchanged source count" do
    test "should not change source count" do
      assert_equal Source.count, @source_count
    end
  end

  shared "decremented source count" do
    test "should decrement source count" do
      assert_equal Source.count, @source_count - 1
    end
  end
  
end

class RequestTestCase

  shared "incremented rating count" do
    test "should increment rating count" do
      assert_equal @rating_count + 1, Rating.count
    end
  end
  
  shared "unchanged rating count" do
    test "should not change rating count" do
      assert_equal @rating_count, Rating.count
    end
  end

  shared "decremented rating count" do
    test "should decrement rating count" do
      assert_equal @rating_count - 1, Rating.count
    end
  end
  
end

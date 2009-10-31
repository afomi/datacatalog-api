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
  
  shared "rating unchanged" do
    test "should not change rating in database" do
      assert_equal @rating_copy, Rating.find_by_id(@rating.id)
      # TODO: use reload
    end
  end
  
  
end

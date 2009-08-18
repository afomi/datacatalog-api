class RequestTestCase

  shared "incremented rating count" do
    test "should increment rating count" do
      source = Source.find_by_id(@source.id)
      assert_equal @rating_count + 1, source.ratings.length
    end
  end
  
  shared "unchanged rating count" do
    test "should not change rating count" do
      source = Source.find_by_id(@source.id)
      assert_equal @rating_count, source.ratings.length
    end
  end

  shared "decremented rating count" do
    test "should decrement rating count" do
      source = Source.find_by_id(@source.id)
      assert_equal @rating_count - 1, source.ratings.length
    end
  end
  
end

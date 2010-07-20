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
      # Worked in MongoMapper 0.7.x
      # assert_equal @rating_copy, Rating.find_by_id(@rating.id)

      original = Rating.find_by_id(@rating.id)
      assert_equal @rating_copy.kind,       original.kind
      assert_equal @rating_copy.user_id,    original.user_id
      assert_equal @rating_copy.source_id,  original.source_id
      assert_equal @rating_copy.comment_id, original.comment_id
      assert_equal @rating_copy.value,      original.value
      assert_equal @rating_copy.text,       original.text
    end
  end
  
end

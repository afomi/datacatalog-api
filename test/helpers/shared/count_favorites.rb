class RequestTestCase

  shared "incremented favorite count" do
    test "should increment favorite count" do
      assert_equal @favorite_count + 1, Favorite.count
    end
  end

  shared "unchanged favorite count" do
    test "should not change favorite count" do
      assert_equal @favorite_count, Favorite.count
    end
  end

  shared "decremented favorite count" do
    test "should decrement favorite count" do
      assert_equal @favorite_count - 1, Favorite.count
    end
  end

end

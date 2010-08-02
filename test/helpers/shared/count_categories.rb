class RequestTestCase

  shared "incremented category count" do
    test "should increment category count" do
      assert_equal @category_count + 1, Category.count
    end
  end

  shared "unchanged category count" do
    test "should not change category count" do
      assert_equal @category_count, Category.count
    end
  end

  shared "decremented category count" do
    test "should decrement category count" do
      assert_equal @category_count - 1, Category.count
    end
  end

end

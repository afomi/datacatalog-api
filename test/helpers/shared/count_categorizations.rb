class RequestTestCase

  shared "incremented categorization count" do
    test "should increment categorization count" do
      assert_equal @categorization_count + 1, Categorization.count
    end
  end

  shared "unchanged categorization count" do
    test "should not change categorization count" do
      assert_equal @categorization_count, Categorization.count
    end
  end

  shared "decremented categorization count" do
    test "should decrement categorization count" do
      assert_equal @categorization_count - 1, Categorization.count
    end
  end

end

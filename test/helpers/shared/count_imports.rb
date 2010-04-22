class RequestTestCase

  shared "incremented import count" do
    test "should increment import count" do
      assert_equal @import_count + 1, Import.count
    end
  end
  
  shared "unchanged import count" do
    test "should not change import count" do
      assert_equal @import_count, Import.count
    end
  end

  shared "decremented import count" do
    test "should decrement import count" do
      assert_equal @import_count - 1, Import.count
    end
  end
  
end

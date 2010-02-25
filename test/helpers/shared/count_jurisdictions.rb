class RequestTestCase

  shared "incremented jurisdiction count" do
    test "should increment jurisdiction count" do
      assert_equal @jurisdiction_count + 1, Jurisdiction.count
    end
  end
  
  shared "unchanged jurisdiction count" do
    test "should not change jurisdiction count" do
      assert_equal @jurisdiction_count, Jurisdiction.count
    end
  end

  shared "decremented jurisdiction count" do
    test "should decrement jurisdiction count" do
      assert_equal @jurisdiction_count - 1, Jurisdiction.count
    end
  end
  
end

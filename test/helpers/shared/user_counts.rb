class RequestTestCase

  shared "incremented user count" do
    test "should increment user count" do
      assert_equal User.count, @user_count + 1
    end
  end
  
  shared "unchanged user count" do
    test "should not change user count" do
      assert_equal User.count, @user_count
    end
  end

  shared "decremented user count" do
    test "should decrement user count" do
      assert_equal User.count, @user_count - 1
    end
  end
  
end

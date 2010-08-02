class RequestTestCase

  shared "incremented user count" do
    test "should increment user count" do
      assert_equal @user_count + 1, User.count
    end
  end

  shared "unchanged user count" do
    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end

  shared "decremented user count" do
    test "should decrement user count" do
      assert_equal @user_count - 1, User.count
    end
  end

end

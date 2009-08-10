class RequestTestCase

  shared "incremented api_key count" do
    test "should increment api_key count" do
      user = User.find_by_id(@user.id)
      assert_equal @api_key_count + 1, user.api_keys.length
    end
  end
  
  shared "unchanged api_key count" do
    test "should not change api_key count" do
      user = User.find_by_id(@user.id)
      assert_equal @api_key_count, user.api_keys.length
    end
  end

  shared "decremented api_key count" do
    test "should decrement api_key count" do
      user = User.find_by_id(@user.id)
      assert_equal @api_key_count - 1, user.api_keys.length
    end
  end
  
end

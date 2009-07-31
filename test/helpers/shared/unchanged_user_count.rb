module UnchangedUserCount
  
  def self.included(mod)
    mod.test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
end

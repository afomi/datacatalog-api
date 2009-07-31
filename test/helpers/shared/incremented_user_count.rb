module IncrementedUserCount
  
  def self.included(mod)
    mod.test "should increment user count" do
      assert_equal @user_count + 1, User.count
    end
    
  end
  
end

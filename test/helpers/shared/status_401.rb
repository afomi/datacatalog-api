# 401 Unauthorized
module Status401

  def self.included(mod)
    mod.test "status should be 401" do
      assert_equal 401, last_response.status
    end
  end
  
end

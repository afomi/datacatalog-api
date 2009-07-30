# 401 Not Found
module Status404

  def self.included(mod)
    mod.test "status should be 404" do
      assert_equal 404, last_response.status
    end
  end
  
end

# 400 BadRequest
module Status400

  def self.included(mod)
    mod.test "status should be 400" do
      assert_equal 400, last_response.status
    end
  end
  
end

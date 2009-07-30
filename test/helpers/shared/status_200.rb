# 200 OK
module Status200

  def self.included(mod)
    mod.test "status should be 200 OK" do
      assert_equal 200, last_response.status
    end
  end
  
end

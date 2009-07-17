module SharedTests
  
  def self.included(including_module)
    including_module.test "should have JSON content type" do
      assert_equal last_response.headers["Content-Type"], "application/json"
    end
  end
  
end

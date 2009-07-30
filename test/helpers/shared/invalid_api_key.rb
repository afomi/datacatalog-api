module InvalidApiKey

  def self.included(mod)
    mod.test "status should be 401 Not Authorized" do
      assert_equal 401, last_response.status
    end
  
    mod.test "body should say the API key is invalid" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_api_key", parsed_response_body["errors"]
    end
  end
  
end

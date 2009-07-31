module InvalidApiKey

  def self.included(mod)
    mod.should_give Status401
  
    mod.test "body should say the API key is invalid" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_api_key", parsed_response_body["errors"]
    end
  end
  
end

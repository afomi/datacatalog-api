# Please note that this is intentionally *not* an authentication
# error. It is the result of passing an API key when it is not
# allowed. In order words, some actions can only be done
# anonymously.

module ApiKeyNotAllowed

  def self.included(mod)
    mod.should_give Status400
    
    mod.test "body should say the API key is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "api_key", parsed_response_body["errors"]["invalid_params"]
    end
    
  end
  
end

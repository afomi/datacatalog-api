module ApiKeyNotAllowed

  def self.included(mod)
    # should_give Status400
    
    mod.test "body should explain the problem" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "api_key", parsed_response_body["errors"]["invalid_params"]
    end
    
  end
  
end

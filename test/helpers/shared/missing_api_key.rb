module MissingApiKey
  
  def self.included(mod)
    mod.should_give Status401

    mod.test "body should say the API key is missing" do
      assert_include "errors", parsed_response_body
      assert_include "missing_api_key", parsed_response_body["errors"]
    end
  end
  
end

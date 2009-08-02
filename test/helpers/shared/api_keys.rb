class RequestTestCase

  # Please note that this is intentionally *not* an authentication
  # error. It is the result of passing an API key when it is not
  # allowed. In order words, some actions can only be done
  # anonymously.
  shared "return 400 because the API key is not allowed" do
    use "return 400 Bad Request"
    
    test "body should say the API key is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "api_key", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  shared "return 401 because the API key is invalid" do
    use "return 401 Unauthorized"
    
    test "body should say the API key is invalid" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_api_key", parsed_response_body["errors"]
    end
  end
  
  shared "return 401 because the API key is missing" do
    use "return 401 Unauthorized"
    
    test "body should say the API key is missing" do
      assert_include "errors", parsed_response_body
      assert_include "missing_api_key", parsed_response_body["errors"]
    end
  end
  
  shared "return 401 because the API key is unauthorized" do
    use "return 401 Unauthorized"
    
    test "body should say the API key is unauthorized" do
      assert_include "errors", parsed_response_body
      assert_include "unauthorized_api_key", parsed_response_body["errors"]
    end
  end

end

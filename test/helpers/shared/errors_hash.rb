class RequestTestCase

  shared "return errors hash saying created_at is invalid" do
    test "body should say 'created_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "created_at", parsed_response_body["errors"]["invalid_params"]
    end
  end

  shared "return errors hash saying updated_at is invalid" do
    test "body should say 'updated_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "updated_at", parsed_response_body["errors"]["invalid_params"]
    end
  end

  shared "return errors hash saying user_id is invalid" do
    test "body should say 'user_id' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "user_id", parsed_response_body["errors"]["invalid_params"]
    end
  end

  shared "return errors hash saying admin is invalid" do
    test "body should say 'admin' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "admin", parsed_response_body["errors"]["invalid_params"]
    end
  end

  shared "return errors hash saying creator_api_key is invalid" do
    test "body should say 'creator_api_key' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "creator_api_key", parsed_response_body["errors"]["invalid_params"]
    end
  end

  shared "return errors hash saying junk is invalid" do
    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end

  shared "return errors hash saying api_key is invalid" do
    test "body should say the API key is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "api_key", parsed_response_body["errors"]["invalid_params"]
    end
  end

  shared "return errors hash saying key_type is missing" do
    test "body should say 'key_type' is missing" do
      assert_include "errors", parsed_response_body
      assert_include "missing_params", parsed_response_body["errors"]
      assert_include "key_type", parsed_response_body["errors"]["missing_params"]
    end
  end

  shared "return errors hash saying key_type has invalid value" do
    test "body should say 'key_type' has an invalid value" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_values_for_params", parsed_response_body["errors"]
      assert_include "key_type", parsed_response_body["errors"]["invalid_values_for_params"]
    end
  end

  shared "return errors hash saying title is missing" do
    test "body should say 'title' is missing" do
      assert_include "errors", parsed_response_body
      assert_include "title", parsed_response_body["errors"]
      assert_include "can't be empty", parsed_response_body["errors"]["title"]
    end
  end
  
  shared "return errors hash saying url is missing" do
    test "body should say 'url' is missing" do
      assert_include "errors", parsed_response_body
      assert_include "url", parsed_response_body["errors"]
      assert_include "can't be empty", parsed_response_body["errors"]["url"]
    end
  end
  
  shared "return errors hash saying url scheme is incorrect" do
    test "body should say url scheme is incorrect" do
      assert_include "errors", parsed_response_body
      assert_include "url", parsed_response_body["errors"]
      assert_include "URI scheme must be http or ftp", parsed_response_body["errors"]["url"]
    end
  end

end

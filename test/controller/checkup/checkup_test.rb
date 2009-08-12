require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CheckupTest < RequestTestCase

  # - - - - - - - - - -
  
  shared "valid API key" do
    test "should indicate valid API key" do
      assert_include "valid_api_key", parsed_response_body
      assert_equal true, parsed_response_body["valid_api_key"]
    end
  end

  shared "invalid API key" do
    test "should indicate invalid API key" do
      assert_include "valid_api_key", parsed_response_body
      assert_equal false, parsed_response_body["valid_api_key"]
    end
  end

  shared "anonymous" do
    test "should indicate anonymous credentials" do
      assert_include "anonymous", parsed_response_body
      assert_equal true, parsed_response_body["anonymous"]
    end
  end

  shared "not anonymous" do
    test "should indicate non-anonymous credentials" do
      assert_include "anonymous", parsed_response_body
      assert_equal false, parsed_response_body["anonymous"]
    end
  end

  # - - - - - - - - - -

  context "anonymous user : get /checkup" do
    before do
      get '/checkup'
    end

    use "return 200 OK"
    use "anonymous"
    
    test "should reveal resources available" do
      assert_include "resources", parsed_response_body
      assert_include "/",       parsed_response_body["resources"]
      assert_include "checkup", parsed_response_body["resources"]
    end
  end
  
  context "incorrect user : get /checkup" do
    before do
      get '/checkup', :api_key => "does_not_exist_in_database"
    end

    use "return 200 OK"
    use "invalid API key"
  end
  
  context "normal user : get /checkup" do
    before do
      get '/checkup', :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 OK"
    use "not anonymous"
    use "valid API key"

    test "should reveal resources available" do
      assert_include "resources", parsed_response_body
      resources = parsed_response_body["resources"]
      assert_include "/"             , resources
      assert_include "checkup"       , resources
      assert_include "comments"      , resources
      assert_include "documents"     , resources
      assert_include "sources"       , resources
      assert_include "users"         , resources
    end
  end

  context "admin user : get /checkup" do
    before do
      get '/checkup', :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 OK"
    use "not anonymous"
    use "valid API key"

    test "should indicate admin permissions" do
      assert_include "admin", parsed_response_body
      assert_equal true, parsed_response_body["admin"]
    end

    test "should reveal resources available" do
      assert_include "resources", parsed_response_body
      resources = parsed_response_body["resources"]
      assert_include "/"             , resources
      assert_include "checkup"       , resources
      assert_include "comments"      , resources
      assert_include "documents"     , resources
      assert_include "sources"       , resources
      assert_include "users"         , resources
    end
  end

end

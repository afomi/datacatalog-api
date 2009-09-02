require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CheckupTest < RequestTestCase
  
  def app
    DataCatalog::Checkup
  end

  # - - - - - - - - - -

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

  # - - - - - - - - - -
  
  context "anonymous : get /" do
    before do
      get '/'
    end

    use "return 200 OK"
    use "anonymous"
    
    test "should reveal resources available" do
      assert_include "resources", parsed_response_body
      resources = parsed_response_body["resources"]
      assert_include "/"         , resources
      assert_include "checkup"   , resources
    end
    
    test "should not have a user_id" do
      assert_not_include "user_id", parsed_response_body
    end
  end
  
  context "incorrect API key : get /" do
    before do
      get '/', :api_key => "does_not_exist_in_database"
    end
  
    use "return 200 OK"
    use "invalid API key"
  end
  
  context "normal API key : get /" do
    before do
      get '/', :api_key => @normal_user.primary_api_key
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
      assert_include "organizations" , resources
      assert_include "sources"       , resources
      assert_include "users"         , resources
    end

    test "should have correct user_id" do
      assert_equal @normal_user.id, parsed_response_body["user_id"]
    end
  end
  
  context "curator API key : get /" do
    before do
      get '/', :api_key => @curator_user.primary_api_key
    end
    
    use "return 200 OK"
    use "not anonymous"
    use "valid API key"
  
    test "should indicate curator permissions" do
      assert_include "curator", parsed_response_body
      assert_equal true, parsed_response_body["curator"]
    end
  
    test "should reveal resources available" do
      assert_include "resources", parsed_response_body
      resources = parsed_response_body["resources"]
      assert_include "/"             , resources
      assert_include "checkup"       , resources
      assert_include "comments"      , resources
      assert_include "documents"     , resources
      assert_include "organizations" , resources
      assert_include "sources"       , resources
      assert_include "users"         , resources
    end

    test "should have correct user_id" do
      assert_equal @curator_user.id, parsed_response_body["user_id"]
    end
  end
  
  context "admin API key : get /" do
    before do
      get '/', :api_key => @admin_user.primary_api_key
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
      assert_include "organizations" , resources
      assert_include "sources"       , resources
      assert_include "users"         , resources
    end

    test "should have correct user_id" do
      assert_equal @admin_user.id, parsed_response_body["user_id"]
    end
  end

end

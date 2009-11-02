require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class ResourcesTest < RequestTestCase
  
  def app
    DataCatalog::Resources
  end

  def resources_from_response_body
    assert_include "members", parsed_response_body
    members = parsed_response_body["members"]
    members.map { |r| r["href"] }
  end
  
  shared "return a list of all resources" do
    test "should list all resources" do
      resources = resources_from_response_body
      assert_include "/"              , resources
      assert_include "/categories"    , resources
      assert_include "/checkup"       , resources
      assert_include "/comments"      , resources
      assert_include "/documents"     , resources
      assert_include "/notes"         , resources
      assert_include "/organizations" , resources
      assert_include "/ratings"       , resources
      assert_include "/resources"     , resources
      assert_include "/sources"       , resources
      assert_include "/tags"          , resources
      assert_include "/users"         , resources
    end
  end
  
  context "anonymous : get /" do
    before do
      get '/'
    end

    use "return 200 OK"
    
    test "should reveal anonymous resources" do
      resources = resources_from_response_body
      assert_include "/"          , resources
      assert_include "/checkup"   , resources
      assert_include "/resources" , resources
    end
  end
  
  context "incorrect API key : get /" do
    before do
      get '/', :api_key => BAD_API_KEY
    end
  
    use "return 401 because the API key is invalid"
  end

  context "normal API key : get /" do
    before do
      get '/', :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 OK"
    use "return a list of all resources"
  end
  
  context "curator API key : get /" do
    before do
      get '/', :api_key => @curator_user.primary_api_key
    end
    
    use "return 200 OK"
    use "return a list of all resources"
  end

  context "admin API key : get /" do
    before do
      get '/', :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 OK"
    use "return a list of all resources"
  end

end

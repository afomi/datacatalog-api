require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

# The root action(s) provide basic information about the API.
#
# Passing an API key as a parameter is not allowed. Why not?
#
# * There is nothing about 'get /' that involves authentication. Checking
#   authentication wouldn't serve any purpose. Not checking means that
#   this action can be very simple.
#
# * On the other hand, accepting an API key parameter would imply that the
#   web service does some sort of verification. Doing that verification
#   would make the action more complicated and would also slow it down
#   (since we would need to lookup the API key.)

class RootControllerTest < RequestTestCase

  def app; DataCatalog::Root end

  context "anonymous : get /" do
    before :all do
      get '/'
    end

    use "return 200 Ok"

    test "body has name" do
      assert_equal "National Data Catalog API", parsed_response_body["name"]
    end
    
    test "body has correct creator" do
      assert_equal "The Sunlight Labs", parsed_response_body["creator"]
    end
    
    test "body has correct version" do
      assert_equal "0.10", parsed_response_body["version"]
    end
    
    test "body has list of resources" do
      assert_include "resources", parsed_response_body
      resources = parsed_response_body["resources"]
      assert_include "/"             , resources
      assert_include "checkup"       , resources
    end
    
    test "body contains only the expected keys" do
      assert_equal [], parsed_response_body.keys - %w(
        name
        creator
        version
        resources
      )
    end
  end
  
  context "incorrect API key : get /" do
    before :all do
      get '/', :api_key => "does_not_exist_in_database"
    end
    
    use "return 400 because the API key is not allowed"
  end

  context "normal API key : get /" do
    before :all do
      get '/', :api_key => @normal_user.primary_api_key
    end
    
    use "return 400 because the API key is not allowed"
  end
  
  context "admin API key : get /" do
    before :all do
      get '/', :api_key => @admin_user.primary_api_key
    end
    
    use "return 400 because the API key is not allowed"
  end

end

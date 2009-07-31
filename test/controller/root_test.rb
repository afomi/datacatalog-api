require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module InformationalDataAboutApi end

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
  
  before :all do
    reset_users
    @admin       = create_admin_user
    @confirmed   = create_confirmed_user
    @unconfirmed = create_unconfirmed_user
  end
  
  context "anonymous user : get /" do
    before :all do
      get '/'
    end
    should_give InformationalDataAboutApi
  end
  
  context "incorrect user : get /" do
    doing {
      get '/', :api_key => "does_not_exist_in_database"
    }.should_give ApiKeyNotAllowed
  end

  context "unconfirmed user : get /" do
    doing {
      get '/', :api_key => @unconfirmed.api_key
    }.should_give ApiKeyNotAllowed
  end

  context "confirmed user : get /" do
    doing {
      get '/', :api_key => @confirmed.api_key
    }.should_give ApiKeyNotAllowed
  end

  context "admin user : get /" do
    doing {
      get '/', :api_key => @admin.api_key
    }.should_give ApiKeyNotAllowed
  end
  
  # test "body should explain the problem" do
  #   assert_include "errors", parsed_response_body
  #   assert_include "invalid_params", parsed_response_body["errors"]
  #   assert_include "junk", parsed_response_body["errors"]["invalid_params"]
  # end

end

module InformationalDataAboutApi
  def self.included(mod)
    mod.should_give Status200
    
    mod.test "body has name" do
      assert_equal "National Data Catalog API", parsed_response_body["name"]
    end

    mod.test "body has correct creator" do
      assert_equal "The Sunlight Labs", parsed_response_body["creator"]
    end

    mod.test "body has correct version" do
      assert_equal "0.10", parsed_response_body["version"]
    end
    
    mod.test "body has list of resources" do
      expected = [
        {
          "sources" => "http://localhost:4567/sources"
        }
      ]
      assert_equal expected, parsed_response_body["resources"]
    end

    mod.test "body contains only the expected keys" do
      assert_equal [], parsed_response_body.keys - %w(
        authentication_note
        authentication_status
        creator
        name
        resources
        version
      )
    end
  end
end

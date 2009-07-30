require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module InformationalDataAboutApi end

# Basic information about the API as a whole
#
# API key not allowed because accepting it would imply that the web
# service would actually verify it.
#
# But there is nothing about 'get /' that involves authentication,
# so I prefer not to check for 'api_key'. This also will make the
# route faster because no API key lookup is needed.
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

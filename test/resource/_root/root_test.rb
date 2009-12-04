require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

# The root action(s) provide basic information about the API.
class RootResourceTest < RequestTestCase

  def app; DataCatalog::Root end

  shared "return api level metadata" do
    use "return 200 Ok"

    test "body has name" do
      assert_equal "National Data Catalog API", parsed_response_body["name"]
    end
    
    test "body has correct version" do
      assert_equal "0.4.3", parsed_response_body["version"]
    end
    
    test "body has list of resources" do
      assert_include "resource_directory", parsed_response_body
      expected = { "href" => "/resources" }
      assert_equal expected, parsed_response_body["resource_directory"]
    end
    
    test "body contains only the expected keys" do
      assert_equal [], parsed_response_body.keys - %w(
        creator
        documentation
        name
        project_page
        resource_directory
        source_code
        version
      )
    end
  end
  
  context "get /" do
    context "anonymous" do
      before :all do
        get '/'
      end

      use "return api level metadata"
    end

    context "incorrect API key" do
      before :all do
        get '/', :api_key => BAD_API_KEY
      end

      use "return 401 because the API key is invalid"
    end

    context "normal API key" do
      before :all do
        get '/', :api_key => @normal_user.primary_api_key
      end

      use "return api level metadata"
    end

    context "admin API key" do
      before :all do
        get '/', :api_key => @admin_user.primary_api_key
      end

      use "return api level metadata"
    end
  end

end

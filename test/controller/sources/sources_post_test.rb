require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesPostControllerTest < RequestTestCase

  context "anonymous user : post /sources" do
    before :all do
      post '/sources'
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : post /sources" do
    before :all do
      post '/sources', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "unconfirmed user : post /sources" do
    before :all do
      post '/sources', :api_key => @unconfirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "confirmed user : post /sources" do
    before :all do
      post '/sources', :api_key => @confirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "admin user : post /sources with correct params" do
    before :all do
      @source_count = Source.count
      post '/sources', {
        :api_key   => @admin_user.primary_api_key,
        :url       => "http://data.gov/sources/A"
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented source count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_user_uri = "http://localhost:4567/sources/" + parsed_response_body["id"]
      assert_equal new_user_uri, last_response.headers["Location"]
    end
    
    test "body should have correct url" do
      assert_equal "http://data.gov/sources/A", parsed_response_body["url"]
    end
    
    test "url should be correct in database" do
      source = Source.find_by_id(parsed_response_body["id"])
      assert_equal "http://data.gov/sources/A", source.url
    end
  end
  
  # Not applicable at present
  # context "admin user : post /sources with protected param" do
  # end

  context "admin user : post /sources with extra param" do
    before :all do
      post '/sources', {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/sources/A",
        :extra   => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
  
    test "body should explain the problem" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "extra", parsed_response_body["errors"]["invalid_params"]
    end
  end

end

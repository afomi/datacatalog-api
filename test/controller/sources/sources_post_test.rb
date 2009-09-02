require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesPostControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    @source_count = Source.count
  end

  # - - - - - - - - - -

  shared "successful POST to sources" do
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented source count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/sources/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct url" do
      assert_equal "http://data.gov/original", parsed_response_body["url"]
    end
    
    test "text should be correct in database" do
      source = Source.find_by_id(parsed_response_body["id"])
      assert_equal "http://data.gov/original", source.url
    end
  end
  
  # - - - - - - - - - -

  context "anonymous : post /" do
    before do
      post "/"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged source count"
  end
  
  context "incorrect API key : post /" do
    before do
      post "/", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged source count"
  end
  
  context "normal API key : post /" do
    before do
      post "/", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end
  
  # - - - - - - - - - -

  context "admin API key : post / with protected param" do
    before do
      post "/", {
        :api_key    => @admin_user.primary_api_key,
        :url     => "http://data.gov/original",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged source count"
    use "return errors hash saying updated_at is invalid"
  end
  
  context "admin API key : post / with invalid param" do
    before do
      post "/", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/original",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged source count"
    use "return errors hash saying junk is invalid"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @curator_user.primary_api_key,
        :url     => "http://data.gov/original"
      }
    end
    
    use "successful POST to sources"
  end
  
  context "admin API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/original"
      }
    end

    use "successful POST to sources"
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesGetOneControllerTest < RequestTestCase

  before do
    source = Source.create :url => "http://data.gov/sources/A"
    @id = source.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : get /sources/:id" do
    before do
      get "/sources/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /sources/:id" do
    before do
      get "/sources/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal API key : get /sources/:id" do
    before do
      get "/sources/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : get /sources/:fake_id : not found" do
    before do
      get "/sources/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin API key : get /sources/:id : found" do
    before do
      get "/sources/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct url" do
      assert_equal "http://data.gov/sources/A", parsed_response_body["url"]
    end
  end

end

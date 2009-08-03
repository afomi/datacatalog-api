require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SourcesGetOneControllerTest < RequestTestCase

  def create_example_source
    Source.create :url => "http://data.gov/sources/A"
  end

  context "anonymous user : get /sources/:id" do
    before :all do
      @id = create_example_source.id
      get "/sources/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /sources/:id" do
    before :all do
      @id = create_example_source.id
      get "/sources/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "unconfirmed user : get /sources/:id" do
    before :all do
      @id = create_example_source.id
      get "/sources/#{@id}", :api_key => @unconfirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "confirmed user : get /sources/:id" do
    before :all do
      @id = create_example_source.id
      get "/sources/#{@id}", :api_key => @confirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  context "admin user : get /sources/:fake_id : not found" do
    before :all do
      Source.create :url => "http://data.gov/sources/A"
      @fake_id = get_fake_mongo_object_id
      get "/sources/#{@fake_id}", :api_key => @admin_user.api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  context "admin user : get /sources/:id : found" do
    before :all do
      source = Source.create :url => "http://data.gov/sources/A"
      @id = source.id
      get "/sources/#{@id}", :api_key => @admin_user.api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct url" do
      assert_equal "http://data.gov/sources/A", parsed_response_body["url"]
    end
  end

end

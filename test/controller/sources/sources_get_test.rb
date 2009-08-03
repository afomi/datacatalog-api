require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class GetSourcesControllerTest < RequestTestCase
  
  context "anonymous user : get /sources" do
    before :all do
      get '/sources'
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /sources" do
    before :all do
      get '/sources', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "unconfirmed user : get /sources" do
    before :all do
      get '/sources', :api_key => @unconfirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "confirmed user : get /sources" do
    before :all do
      get '/sources', :api_key => @confirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  context "admin user : get /sources : 0" do
    before :all do
      get '/sources', :api_key => @admin_user.api_key
    end
    
    use "return 200 Ok"
    use "return an empty response body"
  end
  
  context "admin user : get /sources : 2" do
    before :all do
      Source.create :url => "http://data.gov/sources/A"
      Source.create :url => "http://data.gov/sources/B"
      get '/sources', :api_key => @admin_user.api_key
    end
    
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end
  
    test "body should have correct urls" do
      assert_equal "http://data.gov/sources/A", parsed_response_body[0]["url"]
      assert_equal "http://data.gov/sources/B", parsed_response_body[1]["url"]
    end
        
    test "body should have created_at" do
      assert_include "created_at", parsed_response_body[0]
      assert_include "created_at", parsed_response_body[1]
    end
        
    test "body should have updated_at" do
      assert_include "updated_at", parsed_response_body[0]
      assert_include "updated_at", parsed_response_body[1]
    end
  
    test "body should have id" do
      assert_include "id", parsed_response_body[0]
      assert_include "id", parsed_response_body[1]
    end
        
    test "body should not have _id" do
      assert_not_include "_id", parsed_response_body[0]
      assert_not_include "_id", parsed_response_body[1]
    end
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

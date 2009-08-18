require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class TagsGetOneControllerTest < RequestTestCase

  before do
    tag = Tag.create :text => "Tag A"
    @id = tag.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous user : get /tags/:id" do
    before do
      get "/tags/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /tags/:id" do
    before do
      get "/tags/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal user : get /tags/:id" do
    before do
      get "/tags/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  # - - - - - - - - - -
  
  context "admin user : get /tags/:fake_id : not found" do
    before do
      get "/tags/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin user : get /tags/:id : found" do
    before do
      get "/tags/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Tag A", parsed_response_body["text"]
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    user = User.create :text => "User A"
    @id = user.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "attempted GET user with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
  end

  shared "successful GET user with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "User A", parsed_response_body["text"]
    end
  end

  # - - - - - - - - - -

  context "anonymous : get /:id" do
    before do
      get "/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /:id" do
    before do
      get "/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end

  # - - - - - - - - - -

  context "normal API key : get /:fake_id" do
    before do
      get "/#{@fake_id}", :api_key => @normal_user.primary_api_key
    end
    
    use "attempted GET user with :fake_id"
  end

  context "admin API key : get /:fake_id" do
    before do
      get "/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "attempted GET user with :fake_id"
  end

  # - - - - - - - - - -
  
  context "normal API key : get /:id" do
    before do
      get "/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "successful GET user with :id"
  end

  context "admin API key : get /:id" do
    before do
      get "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "successful GET user with :id"
  end

end

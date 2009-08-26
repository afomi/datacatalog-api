require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetOneControllerTest < RequestTestCase

  before do
    user = User.create({
      :name    => "Find Me",
      :email   => "find.me@email.com",
    })
    @id = user.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -
  
  context "anonymous user : get /users/:id" do
    before do
      get "/users/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /users/:id" do
    before do
      get "/users/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal user : get /users/:id" do
    before do
      get "/users/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  # - - - - - - - - - -

  context "admin user : get /users/:fake_id : not found" do
    before do
      get "/users/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  # - - - - - - - - - -

  context "admin user : get /users/:id : found" do
    before do
      get "/users/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct name" do
      assert_equal "Find Me", parsed_response_body["name"]
    end
        
    test "body should have correct email" do
      assert_equal "find.me@email.com", parsed_response_body["email"]
    end
  end
  
end

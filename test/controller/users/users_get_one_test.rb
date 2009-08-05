require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetOneControllerTest < RequestTestCase

  def create_example_user
    User.create({
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    })
  end
  
  context "anonymous user : get /users/:id" do
    before :all do
      @id = create_example_user.id
      get "/users/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /users/:id" do
    before :all do
      @id = create_example_user.id
      get "/users/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "unconfirmed user : get /users/:id" do
    before :all do
      @id = create_example_user.id
      get "/users/#{@id}", :api_key => @unconfirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "confirmed user : get /users/:id" do
    before :all do
      @id = create_example_user.id
      get "/users/#{@id}", :api_key => @confirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  context "admin user : get /users/:fake_id : not found" do
    before :all do
      @fake_id = get_fake_mongo_object_id
      get "/users/#{@fake_id}", :api_key => @admin_user.api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  context "admin user : get /users/:id : found" do
    before :all do
      user = User.create({
        :name    => "Find Me",
        :email   => "find.me@email.com",
        :purpose => "User account for Web application"
      })
      @id = user.id
      get "/users/#{@id}", :api_key => @admin_user.api_key
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

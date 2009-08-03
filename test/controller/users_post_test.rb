require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PostUsersControllerTest < RequestTestCase
  
  context "anonymous user : post /users" do
    before :all do
      post '/users'
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : post /users" do
    before :all do
      post '/users', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "unconfirmed user : post /users" do
    before :all do
      post '/users', :api_key => @unconfirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "confirmed user : post /users" do
    before :all do
      post '/users', :api_key => @confirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "admin user : post /users with correct params" do
    before :all do
      @user_count = User.count
      post '/users', {
        :api_key   => @admin_user.api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :purpose   => "User account for Web application"
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented user count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_user_uri = "http://localhost:4567/users/" + parsed_response_body["id"]
      assert_equal new_user_uri, last_response.headers["Location"]
    end
    
    test "body should have correct name" do
      assert_equal "John Doe", parsed_response_body["name"]
    end

    test "body should have correct email" do
      assert_equal "john.doe@email.com", parsed_response_body["email"]
    end
    
    test "body should have API key" do
      assert parsed_response_body["api_key"]
    end

    test "API key should be 40 characters" do
      assert_equal 40, parsed_response_body["api_key"].length
    end
    
    test "API key should be different from admin key" do
      assert_not_equal @admin_user.api_key, parsed_response_body["api_key"]
    end
    
    test "name should be correct in database" do
      user = User.find_by_id(parsed_response_body["id"])
      assert_equal "John Doe", user.name
    end

    test "email should be correct in database" do
      user = User.find_by_id(parsed_response_body["id"])
      assert_equal "john.doe@email.com", user.email
    end
  end

  context "admin user : post /users with protected param" do
    before :all do
      post '/users', {
        :api_key   => @admin_user.api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :purpose   => "User account for Web application",
        :confirmed => "true"
      }
    end
  
    use "return 400 Bad Request"
  
    test "body should explain the problem" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "confirmed", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin user : post /users with extra param" do
    before :all do
      post '/users', {
        :api_key   => @admin_user.api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :purpose => "User account for Web application",
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

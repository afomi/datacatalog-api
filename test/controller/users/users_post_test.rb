require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersPostControllerTest < RequestTestCase

  before do
    @user_count = User.count
  end
  
  # - - - - - - - - - -
  
  context "anonymous user : post /users" do
    before do
      post '/users'
    end
    
    use "return 401 because the API key is missing"
    use "unchanged user count"
  end
  
  context "incorrect user : post /users" do
    before do
      post '/users', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged user count"
  end
  
  context "normal user : post /users" do
    before do
      post '/users', :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end

  # - - - - - - - - - -

  context "admin user : post /users : protected param 'admin'" do
    before do
      post '/users', {
        :api_key   => @admin_user.primary_api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :purpose   => "User account for Web application",
        :admin     => true
      }
    end
  
    use "return 400 Bad Request"
  
    test "body should say 'admin' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "admin", parsed_response_body["errors"]["invalid_params"]
    end
  end

  context "admin user : post /users : protected param 'creator_api_key'" do
    before do
      post '/users', {
        :api_key         => @admin_user.primary_api_key,
        :name            => "John Doe",
        :email           => "john.doe@email.com",
        :purpose         => "User account for Web application",
        :admin           => true,
        :creator_api_key => get_fake_api_key("John Doe")
      }
    end
  
    use "return 400 Bad Request"
  
    test "body should say 'creator_api_key' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "creator_api_key", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin user : post /users : extra param 'junk'" do
    before do
      post '/users', {
        :api_key   => @admin_user.primary_api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :purpose => "User account for Web application",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
  
    test "body should say 'extra' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end

  # - - - - - - - - - -
  
  context "admin user : post /users : correct params" do
    before do
      post '/users', {
        :api_key   => @admin_user.primary_api_key,
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
    
    test "body should have API key, 40 characters long" do
      assert_equal 40, parsed_response_body["primary_api_key"].length
    end
    
    test "body should have API key different from admin key" do
      assert_not_equal @admin_user.primary_api_key,
        parsed_response_body["primary_api_key"]
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
  
end

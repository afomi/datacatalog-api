require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PostUsersControllerTest < RequestTestCase
  
  context "anonymous user : post /users" do
    before :all do
      post '/users'
    end
    
    should_give MissingApiKey
  end
  
  context "incorrect user : post /users" do
    before :all do
      post '/users', :api_key => "does_not_exist_in_database"
    end
    
    should_give InvalidApiKey
  end
  
  context "unconfirmed user : post /users" do
    before :all do
      post '/users', :api_key => @unconfirmed_user.api_key
    end
    
    should_give UnauthorizedApiKey
  end
  
  context "confirmed user : post /users" do
    before :all do
      post '/users', :api_key => @confirmed_user.api_key
    end
    
    should_give UnauthorizedApiKey
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
    
    should_give Status201
    should_give TimestampsAndId

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_user_uri = "http://localhost:4567/users/" + parsed_response_body["id"]
      assert_equal new_user_uri, last_response.headers["Location"]
    end
    
    test "body should have correct name value" do
      assert_equal "John Doe", parsed_response_body["name"]
    end

    test "body should have correct email value" do
      assert_equal "john.doe@email.com", parsed_response_body["email"]
    end

    test "should increment user count" do
      assert_equal @user_count + 1, User.count
    end

    test "name should be correct in database" do
      user = User.find(parsed_response_body["id"])
      assert_equal "John Doe", user.name
    end

    test "email should be correct in database" do
      user = User.find(parsed_response_body["id"])
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
  
    should_give Status400
  
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
        :junk    => "This is junk"
      }
    end
  
    should_give Status400
  
    test "body should explain the problem" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
end

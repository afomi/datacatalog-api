require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class GetUsersControllerTest < RequestTestCase

  before :all do
    reset_users
    @admin       = create_admin_user
    @confirmed   = create_confirmed_user
    @unconfirmed = create_unconfirmed_user
    User.create({
      :_id     => "999",
      :name    => "Find Me",
      :email   => "find.me@email.com",
      :purpose => "User account for Web application"
    })
  end
  
  context "anonymous user : get /users" do
    doing {
      get '/users'
    }.should_give MissingApiKey
  end
  
  context "incorrect user : get /users" do
    doing {
      get '/users', :api_key => "does_not_exist_in_database"
    }.should_give InvalidApiKey
  end

  context "unconfirmed user : get /users" do
    doing {
      get '/users', :api_key => @unconfirmed.api_key
    }.should_give UnauthorizedApiKey
  end

  context "confirmed user : get /users" do
    doing {
      get '/users', :api_key => @confirmed.api_key
    }.should_give UnauthorizedApiKey
  end
  
  context "admin user : get /users" do
    before :all do
      get '/users', :api_key => @admin.api_key
    end
    
    should_give Status200
    
    test "body should have 4 top level elements" do
      assert_equal parsed_response_body.length, 4
    end
  
    test "body should have correct name value" do
      assert_equal "Admin", parsed_response_body[0]["name"]
    end
        
    test "body should have correct email value" do
      assert_equal "admin@inter.net", parsed_response_body[0]["email"]
    end
        
    test "body should have created_at" do
      assert_include "created_at", parsed_response_body[0]
    end
        
    test "body should have updated_at" do
      assert_include "updated_at", parsed_response_body[0]
    end
        
    test "body should have _id" do
      assert_include "_id", parsed_response_body[0]
    end
  end

  context "admin user : get /users/7820 : not found" do
    before :all do
      get '/users/7820', :api_key => @admin.api_key
    end
    
    should_give Status404

    test "body should be empty" do
      assert_equal [], parsed_response_body
    end
  end

  context "admin user : get /users/999 : found" do
    before :all do
      get '/users/999', :api_key => @admin.api_key
    end
    
    should_give Status200

    test "body should have correct name value" do
      assert_equal "Find Me", parsed_response_body["name"]
    end
        
    test "body should have correct email value" do
      assert_equal "find.me@email.com", parsed_response_body["email"]
    end

  end
  
end

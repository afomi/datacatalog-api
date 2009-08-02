require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class GetUsersControllerTest < RequestTestCase
  
  context "anonymous user : get /users" do
    before :all do
      get '/users'
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /users" do
    before :all do
      get '/users', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "unconfirmed user : get /users" do
    before :all do
      get '/users', :api_key => @unconfirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "confirmed user : get /users" do
    before :all do
      get '/users', :api_key => @confirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "admin user : get /users" do
    before :all do
      get '/users', :api_key => @admin_user.api_key
    end
    
    use "return 200 Ok"
    
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end
  
    test "body should have correct name" do
      assert_equal "Admin", parsed_response_body[0]["name"]
    end
        
    test "body should have correct email" do
      assert_equal "admin@inter.net", parsed_response_body[0]["email"]
    end
        
    test "body should have created_at" do
      assert_include "created_at", parsed_response_body[0]
    end
        
    test "body should have updated_at" do
      assert_include "updated_at", parsed_response_body[0]
    end
  
    test "body should have id" do
      assert_include "id", parsed_response_body[0]
    end
        
    test "body should not have _id" do
      assert_not_include "_id", parsed_response_body[0]
    end
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

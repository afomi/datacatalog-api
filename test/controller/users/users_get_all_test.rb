require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetAllControllerTest < RequestTestCase
  
  context "anonymous user : get /users" do
    before do
      get '/users'
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /users" do
    before do
      get '/users', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal user : get /users" do
    before do
      get '/users', :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  # - - - - - - - - - -

  context "admin user : get /users" do
    before do
      get '/users', :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "elements should have correct names" do
      names = (0 ... 3).map { |n| parsed_response_body[n]["name"] }
      assert_include "Normal User", names
      assert_include "Curator User", names
      assert_include "Admin User", names
    end

    test "elements should have correct emails" do
      emails = (0 ... 3).map { |n| parsed_response_body[n]["email"] }
      assert_include "normal.user@inter.net", emails
      assert_include "curator.user@inter.net", emails
      assert_include "admin.user@inter.net", emails
    end
    
    test "element should have different API keys" do
      keys = (0 ... 3).map { |n| parsed_response_body[n]["primary_api_key"] }
      assert_equal 3, keys.uniq.length
    end

    3.times do |n|
      test "element #{n} should have created_at" do
        assert_include "created_at", parsed_response_body[n]
      end
      
      test "element #{n} should have updated_at" do
        assert_include "updated_at", parsed_response_body[n]
      end

      test "element #{n} should have id" do
        assert_include "id", parsed_response_body[n]
      end
      
      test "element #{n} should not have _id" do
        assert_not_include "_id", parsed_response_body[n]
      end

      test "element #{n} should have API key, 40 characters long" do
        assert_equal 40, parsed_response_body[n]["primary_api_key"].length
      end
    end

  end
  
end

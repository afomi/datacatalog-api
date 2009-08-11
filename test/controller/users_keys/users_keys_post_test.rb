require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysPostControllerTest < RequestTestCase

  before do
    @user = User.create({
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    })
    @id = @user.id
    @fake_id = get_fake_mongo_object_id
    @api_key_count = @user.api_keys.length
  end
  
  # - - - - - - - - - -
  
  context "anonymous user : post /users/:id/keys" do
    before do
      post "/users/#{@id}/keys"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged api_key count"
  end
  
  context "incorrect user : post /users/:id/keys" do
    before do
      post "/users/#{@id}/keys",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged api_key count"
  end
  
  context "unconfirmed user : post /users/:id/keys" do
    before do
      post "/users/#{@id}/keys",
        :api_key => @unconfirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end
  
  context "confirmed user : post /users/:id/keys" do
    before do
      post "/users/#{@id}/keys",
        :api_key => @confirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -
  
  context "anonymous user : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged api_key count"
  end
  
  context "incorrect user : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged api_key count"
  end
  
  context "unconfirmed user : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys",
        :api_key => @unconfirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end
  
  context "confirmed user : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys",
        :api_key => @confirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -
  
  context "admin user : post /users/:fake_id/keys with correct params" do
    before do
      post "/users/#{@fake_id}/keys", {
        :api_key => @admin_user.primary_api_key,
        :purpose => "My special purpose!"
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -

  context "admin user : post /users/:id/keys with correct params" do
    before do
      post "/users/#{@id}/keys", {
        :api_key => @admin_user.primary_api_key,
        :purpose => "My special purpose!"
      }
    end
    
    use "return 201 Created"
    use "incremented api_key count"
  
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/users/#{@id}/keys/#{parsed_response_body["id"]}"
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct purpose" do
      assert_equal "My special purpose!", parsed_response_body["purpose"]
    end

    test "API key should be 40 characters long" do
      assert_equal 40, parsed_response_body["api_key"].length
    end
    
    test "API key should be different from admin key" do
      assert_not_equal @admin_user.primary_api_key, parsed_response_body["api_key"]
    end
    
    test "purpose should be correct in database" do
      user = User.find_by_id(@id)
      assert_equal "My special purpose!", user.api_keys[0]["purpose"]
    end
  end

  # context "admin user : post /users/:id/keys with protected param" do
  #
  #   Not applicable...
  #
  #   Since api_key is already screened out by admin validation, it will
  #   not be passed through to the ApiKey params.
  # 
  # end

  context "admin user : post /users/:id/keys with extra param" do
    before do
      post "/users/#{@id}/keys", {
        :api_key => @admin_user.primary_api_key,
        :purpose => "My special purpose!",
        :extra   => "This is an extra parameter (junk)"
      }
    end
    
    use "return 400 Bad Request"

    test "body should say 'extra' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "extra", parsed_response_body["errors"]["invalid_params"]
    end
  end

end

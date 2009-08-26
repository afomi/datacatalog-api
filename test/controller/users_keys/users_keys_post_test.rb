require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysPostControllerTest < RequestTestCase

  before do
    @user = User.create({
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    })
    @user.api_keys << ApiKey.new({
      :api_key  => @user.generate_api_key,
      :key_type => "primary",
      :purpose  => "Primary API key"
    })
    @user.save!
    @api_key_id = @user.api_keys[0].id

    @id = @user.id
    @fake_id = get_fake_mongo_object_id
    @api_key_count = @user.api_keys.length
  end
  
  # - - - - - - - - - -
  
  context "anonymous : post /users/:id/keys" do
    before do
      post "/users/#{@id}/keys"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged api_key count"
  end
  
  context "incorrect API key : post /users/:id/keys" do
    before do
      post "/users/#{@id}/keys",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged api_key count"
  end
  
  context "non owner API key : post /users/:id/keys" do
    before do
      post "/users/#{@id}/keys",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end

  context "owner API key : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys",
        :api_key => @user.api_keys[0].api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -
  
  context "anonymous API key : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged api_key count"
  end
  
  context "incorrect API key : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged api_key count"
  end
  
  context "normal API key : post /users/:fake_id/keys" do
    before do
      post "/users/#{@fake_id}/keys",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : post /users/:fake_id/keys : correct params" do
    before do
      post "/users/#{@fake_id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :key_type => "application",
        :purpose  => "My special purpose!"
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : post /users/:id/keys : missing params" do
    before do
      post "/users/#{@id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :purpose  => "My special purpose!"
      }
    end
    
    use "return 400 Bad Request"
    use "unchanged api_key count"
    
    test "body should say 'key_type' is missing" do
      assert_include "errors", parsed_response_body
      assert_include "missing_params", parsed_response_body["errors"]
      assert_include "key_type", parsed_response_body["errors"]["missing_params"]
    end
  end

  # - - - - - - - - - -

  # context "admin API key : post /users/:id/keys : protected param ''" do
  #
  #   Not applicable...
  #
  #   Since api_key is already screened out by admin validation, it will
  #   not be passed through to the ApiKey params.
  # 
  # end

  context "admin API key : post /users/:id/keys : extra param 'junk'" do
    before do
      post "/users/#{@id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :key_type => "application",
        :purpose  => "My special purpose!",
        :junk     => "This is an extra parameter (junk)"
      }
    end
    
    use "return 400 Bad Request"
  
    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end

  # - - - - - - - - - -

  shared "shared tests for successful users_keys_post_test" do
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
  
    test "API key should be different from primary key" do
      user = User.find_by_id(@id)
      assert_not_equal user.api_keys[0].api_key, parsed_response_body["api_key"]
    end
    
    test "purpose should be correct in database" do
      user = User.find_by_id(@id)
      assert_equal "My special purpose!", user.api_keys[1]["purpose"]
    end
  
    test "key_type should be correct in database" do
      user = User.find_by_id(@id)
      assert_equal "application", user.api_keys[1]["key_type"]
    end
  end
  
  context "owner API key : post /users/:id/keys : correct params" do
    before do
      post "/users/#{@id}/keys", {
        :api_key  => @user.api_keys[0].api_key,
        :key_type => "application",
        :purpose  => "My special purpose!"
      }
    end
    
    use "shared tests for successful users_keys_post_test"
  end

  context "admin API key : post /users/:id/keys : correct params" do
    before do
      post "/users/#{@id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :key_type => "application",
        :purpose  => "My special purpose!"
      }
    end

    use "shared tests for successful users_keys_post_test"
  end

end

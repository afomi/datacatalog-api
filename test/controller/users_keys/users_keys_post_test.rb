require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysPostControllerTest < RequestTestCase

  def app; DataCatalog::Users end

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

  shared "attempted POST api_key with missing params" do
    use "return 400 Bad Request"
    use "unchanged api_key count"
    use "return errors hash saying key_type is missing"
  end
  
  shared "attempted POST api_key with invalid param" do
    use "return 400 Bad Request"
    use "return errors hash saying junk is invalid"
  end

  shared "successful POST api_key" do
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
  # - - - - - - - - - -
  
  context "anonymous : post /:id/keys" do
    before do
      post "/#{@id}/keys"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged api_key count"
  end
  
  context "incorrect API key : post /:id/keys" do
    before do
      post "/#{@id}/keys",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged api_key count"
  end
  
  context "non owner API key : post /:id/keys" do
    before do
      post "/#{@id}/keys",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -
  
  context "anonymous API key : post /:fake_id/keys" do
    before do
      post "/#{@fake_id}/keys"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged api_key count"
  end
  
  context "incorrect API key : post /:fake_id/keys" do
    before do
      post "/#{@fake_id}/keys",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged api_key count"
  end
  
  context "non owner API key : post /:fake_id/keys" do
    before do
      post "/#{@fake_id}/keys",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "unchanged api_key count"
  end
  
  context "owner API key : post /:fake_id/keys" do
    before do
      post "/#{@fake_id}/keys",
        :api_key => @user.api_keys[0].api_key
    end
  
    use "return 404 Not Found"
    use "unchanged api_key count"
  end
  
  context "admin API key : post /:fake_id/keys : correct params" do
    before do
      post "/#{@fake_id}/keys", {
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
  
  context "owner API key : post /:id/keys : missing params" do
    before do
      post "/#{@id}/keys", {
        :api_key  => @user.api_keys[0].api_key,
        :purpose  => "My special purpose!"
      }
    end
    
    use "attempted POST api_key with missing params"
  end
  
  context "admin API key : post /:id/keys : missing params" do
    before do
      post "/#{@id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :purpose  => "My special purpose!"
      }
    end
  
    use "attempted POST api_key with missing params"
  end
  
  # - - - - - - - - - -
  
  # This section is a placeholder for handling protected parameters.
  #
  # Not currently needed since api_key is already screened out by admin
  # validation, it will not be passed through to the ApiKey params.
  
  # - - - - - - - - - -
  
  context "owner API key : post /:id/keys : extra param 'junk'" do
    before do
      post "/#{@id}/keys", {
        :api_key  => @user.api_keys[0].api_key,
        :key_type => "application",
        :purpose  => "My special purpose!",
        :junk     => "This is an extra parameter (junk)"
      }
    end
  
    use "attempted POST api_key with invalid param"
  end
  
  context "admin API key : post /:id/keys : extra param 'junk'" do
    before do
      post "/#{@id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :key_type => "application",
        :purpose  => "My special purpose!",
        :junk     => "This is an extra parameter (junk)"
      }
    end
  
    use "attempted POST api_key with invalid param"
  end
  
  # - - - - - - - - - -
  
  context "owner API key : post /:id/keys : correct params" do
    before do
      post "/#{@id}/keys", {
        :api_key  => @user.api_keys[0].api_key,
        :key_type => "application",
        :purpose  => "My special purpose!"
      }
    end
    
    use "successful POST api_key"
  end
  
  context "admin API key : post /:id/keys : correct params" do
    before do
      post "/#{@id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :key_type => "application",
        :purpose  => "My special purpose!"
      }
    end
  
    use "successful POST api_key"
  end

end

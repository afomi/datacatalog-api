require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersKeysPostTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user_with_primary_key(
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    )
    @api_key_count = @user.api_keys.length
  end

  shared "successful POST api_key" do
    use "return 201 Created"
    use "incremented api_key count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/users/#{@user.id}/keys/#{parsed_response_body["id"]}"
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct purpose" do
      assert_equal "My special purpose!", parsed_response_body["purpose"]
    end

    test "API key should be 40 characters long" do
      assert_equal 40, parsed_response_body["api_key"].length
    end

    test "API key should be different from admin key" do
      assert @admin_user.primary_api_key
      assert parsed_response_body["api_key"]
      assert_not_equal @admin_user.primary_api_key, parsed_response_body["api_key"]
    end

    test "API key should be different from primary key" do
      user = User.find_by_id!(@user.id)
      assert_not_equal user.api_keys[0].api_key, parsed_response_body["api_key"]
    end

    test "purpose should be correct in database" do
      user = User.find_by_id!(@user.id)
      assert_equal "My special purpose!", user.api_keys[1]["purpose"]
    end

    test "key_type should be correct in database" do
      user = User.find_by_id!(@user.id)
      assert_equal "application", user.api_keys[1]["key_type"]
    end
  end

  context "owner API key : post /:id/keys : correct params" do
    before do
      post "/#{@user.id}/keys", {
        :api_key  => @user.primary_api_key,
        :key_type => "application",
        :purpose  => "My special purpose!"
      }
    end

    use "successful POST api_key"
  end

  context "admin API key : post /:id/keys : correct params" do
    before do
      post "/#{@user.id}/keys", {
        :api_key  => @admin_user.primary_api_key,
        :key_type => "application",
        :purpose  => "My special purpose!"
      }
    end

    use "successful POST api_key"
  end

end

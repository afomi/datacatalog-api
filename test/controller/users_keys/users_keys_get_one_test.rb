require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user(
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    )
    @user.api_keys << new_api_key({
      :api_key  => @user.generate_api_key,
      :key_type => "primary",
      :purpose  => "Primary API key"
    })
    @user.save!
  end

  context "owner API key : get /:id/keys/:id : found" do
    before do
      get "/#{@user.id}/keys/#{@user.api_keys[0].id}",
        :api_key => @user.api_keys[0].api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct purpose" do
      assert_equal "Primary API key", parsed_response_body["purpose"]
    end
      
    test "body should have well formed API key" do
      assert_equal 40, parsed_response_body["api_key"].length
    end
      
    test "body should not have _id" do
      assert_not_include "_id", parsed_response_body
    end
      
    test "body should have created_at" do
      assert_include "created_at", parsed_response_body
    end
      
    test "body should not have updated_at" do
      assert_not_include "updated_at", parsed_response_body
    end
  end

end

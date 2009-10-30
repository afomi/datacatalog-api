require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Users end
  
  before do
    @user = create_user(
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    )
    @keys = [
      ApiKey.new({
        :api_key  => get_fake_api_key("1"),
        :key_type => "primary",
        :purpose  => "The primary key"
      }),
      ApiKey.new({
        :api_key  => get_fake_api_key("2"),
        :key_type => "valet",
        :purpose  => "Valet key #1"
      }),
      ApiKey.new({
        :api_key  => get_fake_api_key("3"),
        :key_type => "valet",
        :purpose  => "Valet key #2"
      })
    ]
    @user.api_keys = @keys
    @user.save!
  end
  
  after do
    @user.destroy
  end

  %w(normal curator).each do |role|
    context "#{role} API key : get /:id/keys" do
      before do
        get "/#{@user.id}/keys",
          :api_key => primary_api_key_for(role)
      end

      use "return 200 Ok"
      use "return an empty list response body"
      # This does not seem intuitive. However, it is consistent with:
      # 1. Users     having `permission :read => :basic`
      # 2. UsersKeys having `permission :list => :basic`
    end
  end
  
  context "admin API key : get /:id/keys" do
    before do
      get "/#{@user.id}/keys",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "each element should have correct attributes" do
      parsed_response_body.each do |element|
        assert_include "purpose", element
        assert_include "api_key", element
        assert_include "key_type", element
        assert_include "created_at", element
        assert_include "id", element
        assert_not_include "_id", element
      end
    end
  end
  
end

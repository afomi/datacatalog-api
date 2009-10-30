require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Users end
  
  shared "successful GET of users_keys where key_type is valet" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "valet", element["key_type"]
      end
    end
  end

  context "1 added user" do
    before do
      @user = User.new(
        :name    => "Added User",
        :email   => "added-user@email.com",
        :curator => false,
        :admin   => false
      )

      @keys = [
        ApiKey.new({
          :api_key  => @user.generate_api_key,
          :key_type => "primary",
          :purpose  => "The primary key"
        }),
        ApiKey.new({
          :api_key  => @user.generate_api_key,
          :key_type => "valet",
          :purpose  => "Valet key #1"
        }),
        ApiKey.new({
          :api_key  => @user.generate_api_key,
          :key_type => "valet",
          :purpose  => "Valet key #2"
        })
      ]

      @user.api_keys = @keys
      @user.save!
    end

    # TODO: Search is broken in sinatra_resource 0.3.3
    #
    # context "non owner API key : get / where key_type is valet'" do
    #   before do
    #     get "/#{@user.id}/keys",
    #       :api_key  => @normal_user.primary_api_key,
    #       :filter   => "key_type=valet"
    #   end
    # 
    #   use "return 200 Ok"
    #   use "return an empty list response body"
    # end
    
    # TODO: Search is broken in sinatra_resource 0.3.3
    #
    # context "owner API key : get / where key_type is valet'" do
    #   before do
    #     get "/#{@user.id}/keys",
    #       :api_key  => @user.primary_api_key,
    #       :filter   => "key_type=valet"
    #   end
    # 
    #   use "successful GET of users_keys where key_type is valet"
    # end

    # TODO: Search is broken in sinatra_resource 0.3.3
    #
    # context "admin API key : get / where key_type is valet" do
    #   before do
    #     get "/#{@user.id}/keys",
    #       :api_key  => @admin_user.primary_api_key,
    #       :filter   => "key_type=valet"
    #   end
    # 
    #   use "successful GET of users_keys where key_type is valet"
    # end
  end

end

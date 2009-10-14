require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Users end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of users_keys where key_type is valet" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "valet", element["key_type"]
        assert_shared_attributes element
      end
    end
  end

  # - - - - - - - - - -

  context_ "1 added user" do
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
      @id = @user.id
    end

    # - - - - - - - - - -

    context "anonymous : get /:id/keys" do
      before do
        get "/#{@id}/keys"
      end

      use "return 401 because the API key is missing"
    end

    context "incorrect API key : get /:id/keys" do
      before do
        get "/#{@id}/keys",
          :api_key => "does_not_exist_in_database"
      end

      use "return 401 because the API key is invalid"
    end

    context "non owner API key : get / where key_type is valet'" do
      before do
        get "/#{@id}/keys",
          :key_type => "valet",
          :api_key  => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list response body"
      # TODO: Is this how we want to handle this?
      # Returning 401 seems more appropriate
    end

    context "owner API key : get / where key_type is valet'" do
      before do
        get "/#{@id}/keys",
          :key_type => "valet",
          :api_key  => @user.primary_api_key
      end
    
      use "successful GET of users_keys where key_type is valet"
    end

    context "admin API key : get / where name is 'User 4'" do
      before do
        get "/#{@id}/keys",
          :key_type => "valet",
          :api_key  => @admin_user.primary_api_key
      end
    
      use "successful GET of users_keys where key_type is valet"
    end
  end

end

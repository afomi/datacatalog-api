require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Users end
  
  before do
    user = User.create({
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    })
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
    user.api_keys = @keys
    user.save!
    @id = user.id
  end

  # - - - - - - - - - -
  
  shared "successful GET of 3 api_keys" do
    
    use "return 200 Ok"
    
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end
    
    3.times do |n|
      test "element #{n} should have id" do
        assert_include "id", parsed_response_body[n]
      end
      
      test "element #{n} should have purpose" do
        assert_include "purpose", parsed_response_body[n]
      end
      
      test "element #{n} should have api_key" do
        assert_include "api_key", parsed_response_body[n]
      end
  
      test "element #{n} should have key_type" do
        assert_include "key_type", parsed_response_body[n]
      end
  
      test "element #{n} should not have _id" do
        assert_not_include "_id", parsed_response_body[n]
      end
  
      test "element #{n} should have created_at" do
        assert_include "created_at", parsed_response_body[n]
      end
          
      test "element #{n} should not have updated_at" do
        assert_not_include "updated_at", parsed_response_body[n]
      end
    end
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
  
  context "normal API key : get /:id/keys" do
    before do
      get "/#{@id}/keys",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  # - - - - - - - - - -

  context "curator API key : get /:id/keys" do
    before do
      get "/#{@id}/keys",
        :api_key => @curator_user.primary_api_key
    end
    
    use "successful GET of 3 api_keys"
  end

  context "admin API key : get /:id/keys" do
    before do
      get "/#{@id}/keys",
        :api_key => @admin_user.primary_api_key
    end
    
    use "successful GET of 3 api_keys"
  end
  
end

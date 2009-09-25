require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = User.create({
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    })

    @keys = [
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "primary",
        :purpose  => "The primary key"
      }),
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "application",
        :purpose  => "Key for application #1"
      }),
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "application",
        :purpose  => "Key for application #2"
      }),
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "valet",
        :purpose  => "A valet key"
      })
    ]
    @user.api_keys = @keys
    @user.save!
    
    @api_key_count = @user.api_keys.length
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "return error about attempt to delete primary API key" do
    test "body should explain that you cannot delete a primary API key" do
      assert_include "errors", parsed_response_body
      assert_include "cannot_delete_primary_api_key", parsed_response_body["errors"]
      assert_include "cannot delete a primary API key", parsed_response_body["help_text"]
    end
  end
  
  shared "API key deleted from database" do
    test "API key should be deleted in database" do
      raise "@n must be defined" unless @n
      user = User.find_by_id(@user.id)
      api_key = user.api_keys.find { |x| x.id == @keys[@n].id }
      assert_equal nil, api_key
    end
  end

  # - - - - - - - - - -

  (0 ... 3).each do |n|
    context_ "API key #{n}" do
      context "anonymous : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}"
        end
      
        use "return 401 because the API key is missing"
        use "unchanged api_key count"
      end
        
      context "incorrect API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => "does_not_exist_in_database"
        end
      
        use "return 401 because the API key is invalid"
        use "unchanged api_key count"
      end
        
      context "non owner API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @normal_user.primary_api_key
        end
          
        use "return 401 because the API key is unauthorized"
        use "unchanged api_key count"
      end
      
      # - - - - - - - - - -
      
      context "admin API key : delete /:fake_id/keys/:id" do
        before do
          delete "/#{@fake_id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
        end
        
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end
    end
  end

  # - - - - - - - - - -

  context "admin API key : delete /:fake_id/keys/:fake_id" do
    before do
      delete "/#{@fake_id}/keys/#{@fake_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged api_key count"
  end
    
  context "admin API key : delete /:id/keys/:fake_id" do
    before do
      delete "/#{@user.id}/keys/#{@fake_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged api_key count"
  end
  
  # - - - - - - - - - -
  
  [0].each do |n|
    context_ "Primary API key" do
      context "owner API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @user.api_keys[n].api_key
        end
  
        use "return 409 Conflict"
        use "return error about attempt to delete primary API key"
        use "unchanged api_key count"
      end
  
      context "admin API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
        end
      
        use "return 409 Conflict"
        use "return error about attempt to delete primary API key"
        use "unchanged api_key count"
      end
    end
  end
  
  # - - - - - - - - - -
  
  (1 ... 3).each do |n|
    context_ "API key #{n}" do
      context "owner API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @user.api_keys[n].api_key
          @n = n
        end
  
        use "return 200 Ok"
        use "decremented api_key count"
        use "API key deleted from database"
      end
  
      context "owner API key : double delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @user.api_keys[n].api_key
          # Since @user.api_keys[n].api_key is now deleted (and thus invalid),
          # we must use a different API key.
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @user.api_keys[n - 1].api_key
          @n = n
        end
      
        use "return 404 Not Found"
        use "return an empty response body"
        use "decremented api_key count"
        use "API key deleted from database"
      end
  
      context "admin API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
          @n = n
        end
          
        use "return 200 Ok"
        use "decremented api_key count"
        use "API key deleted from database"
          
        test "body should have correct id" do
          assert_include "id", parsed_response_body
          assert_equal @keys[n].id, parsed_response_body["id"]
        end
      end
  
      context "admin API key : double delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
          @n = n
        end
      
        use "return 404 Not Found"
        use "return an empty response body"
        use "decremented api_key count"
        use "API key deleted from database"
      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysDeleteControllerTest < RequestTestCase

  shared "return error about attempt to delete primary API key" do
    test "body should explain that you cannot delete a primary API key" do
      assert_include "errors", parsed_response_body
      assert_include "cannot_delete_primary_api_key", parsed_response_body["errors"]
    end
  end

  # - - - - - - - - - -

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
  
  (0 ... 3).each do |n|
    context_ "API key #{n}" do
      context "anonymous : delete /users/:id/keys/:id" do
        before do
          delete "/users/#{@user.id}/keys/#{@keys[n].id}"
        end
      
        use "return 401 because the API key is missing"
        use "unchanged api_key count"
      end
        
      context "incorrect API key : delete /users/:id/keys/:id" do
        before do
          delete "/users/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => "does_not_exist_in_database"
        end
      
        use "return 401 because the API key is invalid"
        use "unchanged api_key count"
      end
  
      context "non owner API key : delete /users/:id/keys/:id" do
        before do
          delete "/users/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @normal_user.primary_api_key
        end
          
        use "return 401 because the API key is unauthorized"
        use "unchanged api_key count"
      end
        
      # - - - - - - - - - -
      
      context "admin user : delete /users/:fake_id/keys/:id" do
        before do
          delete "/users/#{@fake_id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
        end
        
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end
        
      context "admin user : delete /users/:fake_id/keys/:fake_id" do
        before do
          delete "/users/#{@fake_id}/keys/#{@fake_id}",
            :api_key => @admin_user.primary_api_key
        end
        
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end
        
      context "admin user : delete /users/:id/keys/:fake_id" do
        before do
          delete "/users/#{@user.id}/keys/#{@fake_id}",
            :api_key => @admin_user.primary_api_key
        end
        
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end

    end
  end
  
  # - - - - - - - - - -
  
  context_ "Primary API key" do
    context "admin user : delete /sources" do
      before do
        delete "/users/#{@user.id}/keys/#{@keys[0].id}",
          :api_key => @admin_user.primary_api_key
      end
      
      use "return 403 Forbidden"
      use "return error about attempt to delete primary API key"
      use "unchanged api_key count"
    end
  end
  
  # - - - - - - - - - -
  
  (1 ... 3).each do |n|
    context_ "API key #{n}" do
      context "admin user : delete /sources" do
        before do
          delete "/users/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
        end
    
        use "return 200 Ok"
        use "decremented api_key count"
    
        test "body should have correct id" do
          assert_include "id", parsed_response_body
          assert_equal @keys[n].id, parsed_response_body["id"]
        end
    
        test "API key should be deleted in database" do
          user = User.find_by_id(@user.id)
          api_key = user.api_keys.find { |x| x.id == @keys[n].id }
          assert_equal nil, api_key
        end
      end

      context "admin user : double delete /users" do
        before do
          delete "/users/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
          delete "/users/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
        end
      
        use "return 404 Not Found"
        use "return an empty response body"
        use "decremented api_key count"
    
        test "API key should be deleted in database" do
          user = User.find_by_id(@user.id)
          api_key = user.api_keys.find { |x| x.id == @keys[n].id }
          assert_equal nil, api_key
        end
      end
    end
  end
  
  # - - - - - - - - - -
  
  context_ "authorized user : delete /users/:id/keys/:id" do
    context "should not be able to delete primary API key" do
      before do
        n = 0
        delete "/users/#{@user.id}/keys/#{@keys[n].id}",
          :api_key => @user.api_keys[n].api_key
      end

      use "return 403 Forbidden"
      use "return error about attempt to delete primary API key"
      use "unchanged api_key count"
    end
  
    context "should delete application API key #1" do
      before do
        n = 1
        delete "/users/#{@user.id}/keys/#{@keys[n].id}",
          :api_key => @user.api_keys[n].api_key
      end
    
      use "return 200 Ok"
      use "decremented api_key count"
    end
    
    context "should delete application API key #2" do
      before do
        n = 2
        delete "/users/#{@user.id}/keys/#{@keys[n].id}",
          :api_key => @user.api_keys[n].api_key
      end
    
      use "return 200 Ok"
      use "decremented api_key count"
    end

    context "should delete valet API key" do
      before do
        n = 3
        delete "/users/#{@user.id}/keys/#{@keys[n].id}",
          :api_key => @user.api_keys[n].api_key
      end
    
      use "return 200 Ok"
      use "decremented api_key count"
    end
  end

end

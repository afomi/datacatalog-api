require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysDeleteControllerTest < RequestTestCase

  before do
    @user = User.create({
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    })

    @keys = [
      ApiKey.new({
        :api_key => @user.generate_api_key,
        :purpose => "The primary key"
      }),
      ApiKey.new({
        :api_key => @user.generate_api_key,
        :purpose => "A secondary key"
      }),
      ApiKey.new({
        :api_key => @user.generate_api_key,
        :purpose => "A secondary key"
      })
    ]
    @user.api_keys = @keys
    @user.save!
    
    @api_key_count = @user.api_keys.length
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  1.times do |n|
  # 
  # 3.times do |n|
    context_ "API key #{n}" do
      context "anonymous user : delete /users/:id/keys/:id" do
        before do
          delete "/users/#{@user.id}/keys/#{@keys[n].id}"
        end
      
        use "return 401 because the API key is missing"
        use "unchanged api_key count"
      end

      context "incorrect user : delete /users/:id/keys/:id" do
        before do
          delete "/users/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => "does_not_exist_in_database"
        end
      
        use "return 401 because the API key is invalid"
        use "unchanged api_key count"
      end

      context "normal user : delete /users/:id/keys/:id" do
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
      
      # - - - - - - - - - -
      
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

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysPutControllerTest < RequestTestCase

  context_ "user with 3 API keys" do
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

    3.times do |n|
      context_ "API key #{n}" do
        context "anonymous user : put /users/:id/keys/:id" do
          before do
            put "/users/#{@user.id}/keys/#{@keys[n].id}"
          end
        
          use "return 401 because the API key is missing"
          use "unchanged api_key count"
        end
        
        context "incorrect user : put /users/:id/keys/:id" do
          before do
            put "/users/#{@user.id}/keys/#{@keys[n].id}",
              :api_key => "does_not_exist_in_database"
          end
        
          use "return 401 because the API key is invalid"
          use "unchanged api_key count"
        end
        
        context "unconfirmed user : put /users/:id/keys/:id" do
          before do
            put "/users/#{@user.id}/keys/#{@keys[n].id}",
              :api_key => @unconfirmed_user.primary_api_key
          end
        
          use "return 401 because the API key is unauthorized"
          use "unchanged api_key count"
        end
        
        context "confirmed user : put /users/:id/keys/:id" do
          before do
            put "/users/#{@user.id}/keys/#{@keys[n].id}",
              :api_key => @confirmed_user.primary_api_key
          end
        
          use "return 401 because the API key is unauthorized"
          use "unchanged api_key count"
        end
        
        # - - - - - - - - - -
        
        context "admin user : put /users/:fake_id/keys/:id : attempt to create : not found" do
          before do
            put "/users/#{@fake_id}/keys/#{@keys[n].id}",
              :api_key => @admin_user.primary_api_key
          end
        
          use "return 404 Not Found"
          use "return an empty response body"
          use "unchanged api_key count"
        end
        
        context "admin user : put /users/:id/keys/:fake_id : attempt to create : not found" do
          before do
            put "/users/#{@user.id}/keys/#{@fake_id}",
              :api_key => @admin_user.primary_api_key
          end
        
          use "return 404 Not Found"
          use "return an empty response body"
          use "unchanged api_key count"
        end
        
        context "admin user : put /users/:fake_id/keys/:fake_id : attempt to create : not found" do
          before do
            put "/users/#{@fake_id}/keys/#{@fake_id}",
              :api_key => @admin_user.primary_api_key
          end
        
          use "return 404 Not Found"
          use "return an empty response body"
          use "unchanged api_key count"
        end
        
        # - - - - - - - - - -
        
        context "admin user : put /users/:id/keys/:id : update : protected param" do
          before do
            @original_created_at = @user.api_keys[n].created_at.dup
            put "/users/#{@user.id}/keys/#{@keys[n].id}", {
              :api_key    => @admin_user.primary_api_key,
              :purpose => "Updated purpose",
              :created_at => (Time.now + 10).to_json
            }
          end
        
          use "return 400 Bad Request"
          use "unchanged api_key count"
                  
          test "body should say 'created_at' is an invalid param" do
            assert_include "errors", parsed_response_body
            assert_include "invalid_params", parsed_response_body["errors"]
            assert_include "created_at", parsed_response_body["errors"]["invalid_params"]
          end
        
          test "created_at should be unchanged in database" do
            user = User.find_by_id(@user.id)
            assert_equal_json_times @original_created_at, user.api_keys[n].created_at
          end

          test "purpose should be unchanged in database" do
            user = User.find_by_id(@user.id)
            api_key = user.api_keys.find { |x| x.id == @keys[n].id }
            assert_equal @keys[n].purpose, api_key.purpose
          end
        end
        
        context "admin user : put /users/:id/keys/:id : update : extra param" do
          before do
            stubbed_time = Time.now + 10
            stub(Time).now {stubbed_time}
            @original_created_at = @user.api_keys[n].created_at.dup
            put "/users/#{@user.id}/keys/#{@keys[n].id}", {
              :api_key => @admin_user.primary_api_key,
              :purpose => "Updated purpose",
              :extra   => "This is an extra parameter (junk)"
            }
          end
        
          use "return 400 Bad Request"
          use "unchanged api_key count"
        
          test "body should say 'extra' is an invalid param" do
            assert_include "errors", parsed_response_body
            assert_include "invalid_params", parsed_response_body["errors"]
            assert_include "extra", parsed_response_body["errors"]["invalid_params"]
          end

          test "created_at should be unchanged in database" do
            user = User.find_by_id(@user.id)
            assert_equal_json_times @original_created_at, user.api_keys[n].created_at
          end
          
          test "purpose should be unchanged in database" do
            user = User.find_by_id(@user.id)
            api_key = user.api_keys.find { |x| x.id == @keys[n].id }
            assert_equal @keys[n].purpose, api_key.purpose
          end
        end

        # - - - - - - - - - -

        context "admin user : put /users/:id/keys/:id : update : correct param" do
          before do
            @original_created_at = @user.api_keys[n].created_at.dup
            put "/users/#{@user.id}/keys/#{@keys[n].id}", {
              :api_key => @admin_user.primary_api_key,
              :purpose => "Updated purpose"
            }
          end
        
          use "return 200 Ok"
          use "unchanged api_key count"

          test "created_at should be unchanged in database" do
            user = User.find_by_id(@user.id)
            assert_equal_json_times @original_created_at, user.api_keys[n].created_at
          end

          test "purpose should be updated in database" do
            user = User.find_by_id(@user.id)
            api_key = user.api_keys.find { |x| x.id == @keys[n].id }
            assert_equal "Updated purpose", api_key.purpose
          end
        end

      end
    end
  end

end

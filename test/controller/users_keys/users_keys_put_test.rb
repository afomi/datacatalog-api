require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysPutControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before :all do
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

    @api_key_count = @user.api_keys.length
    @fake_id = get_fake_mongo_object_id
  end
  
  # - - - - - - - - - -

  shared "unchanged created_at in database" do
    test "created_at should be unchanged in database" do
      raise "@n must be defined" unless @n
      raise "@original_created_at must be defined" unless @original_created_at
      user = User.find_by_id(@user.id)
      assert_equal_json_times @original_created_at, user.api_keys[@n].created_at
    end
  end
  
  shared "unchanged purpose in database" do
    test "purpose should be unchanged in database" do
      raise "@n must be defined" unless @n
      user = User.find_by_id(@user.id)
      api_key = user.api_keys.find { |x| x.id == @keys[@n].id }
      assert_equal @keys[@n].purpose, api_key.purpose
    end
  end
  
  shared "updated purpose in database" do
    test "purpose should be updated in database" do
      raise "@n must be defined" unless @n
      user = User.find_by_id(@user.id)
      api_key = user.api_keys.find { |x| x.id == @keys[@n].id }
      assert_equal "Updated purpose", api_key.purpose
    end
  end
  
  shared "unchanged key_type in database" do
    test "key_type should be unchanged in database" do
      raise "@n must be defined" unless @n
      user = User.find_by_id(@user.id)
      api_key = user.api_keys.find { |x| x.id == @keys[@n].id }
      assert_equal "valet", api_key.key_type
    end
  end

  shared "updated key_type in database" do
    test "key_type should be updated in database" do
      raise "@n must be defined" unless @n
      user = User.find_by_id(@user.id)
      api_key = user.api_keys.find { |x| x.id == @keys[@n].id }
      assert_equal "application", api_key.key_type
    end
  end
  
  shared "attempted PUT users_keys with protected parameter" do
    use "return 400 Bad Request"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "unchanged purpose in database"
    use "return errors hash saying created_at is invalid"
  end
  
  shared "attempted PUT users_keys with invalid parameter" do
    use "return 400 Bad Request"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "unchanged purpose in database"
    use "return errors hash saying junk is invalid"
  end
  
  shared "attempted PUT users_keys with invalid key_type" do
    use "return 400 Bad Request"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "unchanged purpose in database"
    use "return errors hash saying key_type has invalid value"
  end
  
  shared "successful PUT users_keys : update purpose" do
    use "return 200 Ok"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "updated purpose in database"
    use "unchanged key_type in database"
  end

  shared "successful PUT users_keys : update key_type" do
    use "return 200 Ok"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "unchanged purpose in database"
    use "updated key_type in database"
  end
  
  shared "successful PUT users_keys : full update" do
    use "return 200 Ok"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "updated purpose in database"
    use "updated key_type in database"
  end

  # - - - - - - - - - -

  # Tests that apply for all keys
  3.times do |n|
    context_ "API key #{n}" do
      context "anonymous : put /:id/keys/:id" do
        before do
          put "/#{@user.id}/keys/#{@keys[n].id}"
        end
      
        use "return 401 because the API key is missing"
        use "unchanged api_key count"
      end
      
      context "incorrect API key : put /:id/keys/:id" do
        before do
          put "/#{@user.id}/keys/#{@keys[n].id}", {
            :api_key  => "does_not_exist_in_database",
            :key_type => "application"
          }
        end
      
        use "return 401 because the API key is invalid"
        use "unchanged api_key count"
      end
      
      context "non owner API key : put /:id/keys/:id" do
        before do
          put "/#{@user.id}/keys/#{@keys[n].id}", {
            :api_key  => @normal_user.primary_api_key,
            :key_type => "application"
          }
        end
      
        use "return 401 because the API key is unauthorized"
        use "unchanged api_key count"
      end
      
      # - - - - - - - - - -
      
      context "owner API key : put /:id/keys/:fake_id" do
        before do
          put "/#{@user.id}/keys/#{@fake_id}", {
            :api_key  => @user.api_keys[n].api_key,
            :key_type => "application"
          }
        end
      
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end
      
      context "admin API key : put /:id/keys/:fake_id" do
        before do
          put "/#{@user.id}/keys/#{@fake_id}", {
            :api_key  => @admin_user.primary_api_key,
            :key_type => "application"
          }
        end
      
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end
      
      # - - - - - - - - - -
      
      context "admin API key : put /:fake_id/keys/:id" do
        before do
          put "/#{@fake_id}/keys/#{@keys[n].id}", {
            :api_key  => @admin_user.primary_api_key,
            :key_type => "application"
          }
        end
      
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end
      
      context "admin API key : put /:fake_id/keys/:fake_id" do
        before do
          put "/#{@fake_id}/keys/#{@fake_id}",
            :api_key => @admin_user.primary_api_key
        end
      
        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged api_key count"
      end
      
      # - - - - - - - - - -
      
      # This section is a placeholder for handling missing parameters.
      
      # - - - - - - - - - -
      
      context "owner API key : put /:id/keys/:id : protected param 'created_at'" do
        before do
          @original_created_at = @user.api_keys[n].created_at.dup
          put "/#{@user.id}/keys/#{@keys[n].id}", {
            :api_key    => @user.api_keys[n].api_key,
            :purpose    => "Updated purpose",
            :created_at => (Time.now + 10).to_json
          }
          @n = n
        end
        
        use "attempted PUT users_keys with protected parameter"
      end
      
      context "admin API key : put /:id/keys/:id : protected param 'created_at'" do
        before do
          @original_created_at = @user.api_keys[n].created_at.dup
          put "/#{@user.id}/keys/#{@keys[n].id}", {
            :api_key    => @admin_user.primary_api_key,
            :key_type   => "application",
            :purpose    => "Updated purpose",
            :created_at => (Time.now + 10).to_json
          }
          @n = n
        end
      
        use "attempted PUT users_keys with protected parameter"
      end
      
      # - - - - - - - - - -
      
      context "owner API key : put /:id/keys/:id : extra param 'junk'" do
        before do
          stubbed_time = Time.now + 10
          stub(Time).now {stubbed_time}
          @original_created_at = @user.api_keys[n].created_at.dup
          put "/#{@user.id}/keys/#{@keys[n].id}", {
            :api_key  => @user.api_keys[n].api_key,
            :key_type => "application",
            :purpose  => "Updated purpose",
            :junk     => "This is an extra parameter (junk)"
          }
          @n = n
        end
        
        use "attempted PUT users_keys with invalid parameter"
      end
      
      context "admin API key : put /:id/keys/:id : extra param 'junk'" do
        before do
          stubbed_time = Time.now + 10
          stub(Time).now {stubbed_time}
          @original_created_at = @user.api_keys[n].created_at.dup
          put "/#{@user.id}/keys/#{@keys[n].id}", {
            :api_key  => @admin_user.primary_api_key,
            :key_type => "application",
            :purpose  => "Updated purpose",
            :junk     => "This is an extra parameter (junk)"
          }
          @n = n
        end
      
        use "attempted PUT users_keys with invalid parameter"
      end
    end
  end

  # Tests that apply to valet keys
  (1 ... 3).each do |n|
    context "owner API key : put /:id/keys : invalid key_type" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @user.api_keys[n].api_key,
          :key_type => "wrong"
        }
        @n = n
      end
    
      use "attempted PUT users_keys with invalid key_type"
    end
    
    context "admin API key : put /:id/keys : invalid key_type" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @admin_user.primary_api_key,
          :key_type => "wrong"
        }
        @n = n
      end
      use "attempted PUT users_keys with invalid key_type"
    
    end
    
    # - - - - - - - - - -
      
    context "owner API key : put /:id/keys : update purpose : correct params" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key => @user.api_keys[n].api_key,
          :purpose => "Updated purpose"
        }
        @n = n
      end
    
      use "successful PUT users_keys : update purpose"
    end
    
    context "admin API key : put /:id/keys : update purpose : correct params" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key => @admin_user.primary_api_key,
          :purpose => "Updated purpose"
        }
        @n = n
      end
    
      use "successful PUT users_keys : update purpose"
    end

    # - - - - - - - - - -
      
    context "owner API key : put /:id/keys : update key_type : correct params" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @user.api_keys[n].api_key,
          :key_type => "application"
        }
        @n = n
      end
    
      use "successful PUT users_keys : update key_type"
    end
    
    context "admin API key : put /:id/keys : update key_type : correct params" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @admin_user.primary_api_key,
          :key_type => "application"
        }
        @n = n
      end
    
      use "successful PUT users_keys : update key_type"
    end
    
    # - - - - - - - - - -
    
    context "owner API key : put /:id/keys/:id : full update : correct params" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @admin_user.primary_api_key,
          :key_type => "application",
          :purpose  => "Updated purpose"
        }
        @n = n
      end
      
      use "successful PUT users_keys : full update"
    end
      
    context "admin API key : put /:id/keys/:id : full update : correct params" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @admin_user.primary_api_key,
          :key_type => "application",
          :purpose  => "Updated purpose"
        }
        @n = n
      end
      
      use "successful PUT users_keys : full update"
    end
  end

end

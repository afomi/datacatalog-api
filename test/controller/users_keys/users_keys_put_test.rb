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
  end
 
  def lookup_user_and_api_key
    raise "@n must be defined" unless @n
    user = User.find_by_id(@user.id)
    api_key = user.api_keys.detect { |x| x.id == @keys[@n].id }
    [user, api_key]
  end

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
      user, api_key = lookup_user_and_api_key
      assert_equal @keys[@n].purpose, api_key.purpose
    end
  end
 
  shared "updated purpose in database" do
    test "purpose should be updated in database" do
      user, api_key = lookup_user_and_api_key
      assert_equal "Updated purpose", api_key.purpose
    end
  end
 
  shared "unchanged key_type in database" do
    test "key_type should be unchanged in database" do
      user, api_key = lookup_user_and_api_key
      assert_equal @keys[@n].key_type, api_key.key_type
    end
  end
 
  shared "key_type in database is primary" do
    test "key_type should be 'primary' in database" do
      user, api_key = lookup_user_and_api_key
      assert_equal "primary", api_key.key_type
    end
  end

  shared "key_type in database is valet" do
    test "key_type should be 'valet' in database" do
      user, api_key = lookup_user_and_api_key
      assert_equal "valet", api_key.key_type
    end
  end

  shared "key_type in database is application" do
    test "key_type should be 'application' in database" do
      user, api_key = lookup_user_and_api_key
      assert_equal "application", api_key.key_type
    end
  end

  shared "attempted PUT users_keys with invalid key_type" do
    use "return 400 Bad Request"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "unchanged purpose in database"
    use "return errors hash saying key_type has invalid value"
  
    test "return help_text saying you can't change a primary key's key_type" do
      assert_include "valid values for key_type are 'application' or 'valet'", parsed_response_body["help_text"]
    end
  end
  
  shared "attempted PUT users_keys with invalid change to key_type" do
    use "return 400 Bad Request"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "unchanged key_type in database"
    use "return errors hash saying key_type has invalid value"
  
    test "return help_text saying you can't change a primary key's key_type" do
      assert_include "cannot change the key_type of a primary key", parsed_response_body["help_text"]
    end
  end
  
  shared "attempted PUT users_keys with :id without params" do
    use "return 400 Bad Request"
    use "unchanged api_key count"
  
    test "body should say 'no_params'" do
      assert_include "no_params", parsed_response_body["errors"]
    end
  end

  shared "successful PUT users_keys : update purpose" do
    use "return 200 Ok"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "updated purpose in database"
    use "unchanged key_type in database"
  end
 
  shared "successful PUT users_keys : update key_type to application" do
    use "return 200 Ok"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "unchanged purpose in database"
    use "key_type in database is application"
  end
 
  shared "successful PUT users_keys : full update" do
    use "return 200 Ok"
    use "unchanged api_key count"
    use "unchanged created_at in database"
    use "updated purpose in database"
    use "key_type in database is application"
  end
 
  # -----------------------------
  # Tests that apply for all keys
  # -----------------------------
 
  3.times do |n|
    context "API key #{n}" do
      context "owner API key : put /:id/keys/:id : update purpose" do
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
    end
  end
  
  # ------------------------------------
  # Tests that apply to primary key only
  # ------------------------------------
  
  (0 .. 0).each do |n|
    context "owner API key : put /:id/keys/:id : changing primary to application not ok" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @user.api_keys[n].api_key,
          :key_type => "application"
        }
        @n = n
      end
  
      use "attempted PUT users_keys with invalid change to key_type"
    end
  
    context "owner API key : put /:id/keys/:id : changing primary to valet not ok" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @user.api_keys[n].api_key,
          :key_type => "valet"
        }
        @n = n
      end
  
      use "attempted PUT users_keys with invalid change to key_type"
    end
  end
  
  # -----------------------------------
  # Tests that apply to valet keys only
  # -----------------------------------
  
  (1 .. 2).each do |n|
    context "owner API key : put /:id/keys/:id : invalid key_type" do
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
  
    context "owner API key : put /:id/keys/:id without params" do
      before do
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key => @user.primary_api_key
        }
      end
  
      use "attempted PUT users_keys with :id without params"
    end
  
    context "owner API key : put /:id/keys : update key_type" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @user.api_keys[n].api_key,
          :key_type => "application"
        }
        @n = n
      end
  
      use "successful PUT users_keys : update key_type to application"
    end
  
    context "owner API key : put /:id/keys/:id : full update" do
      before do
        @original_created_at = @user.api_keys[n].created_at.dup
        put "/#{@user.id}/keys/#{@keys[n].id}", {
          :api_key  => @user.primary_api_key,
          :key_type => "application",
          :purpose  => "Updated purpose"
        }
        @n = n
      end
  
      use "successful PUT users_keys : full update"
    end
  end

end

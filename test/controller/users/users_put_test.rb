require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersPutControllerTest < RequestTestCase

  before do
    @user = User.create({
      :name    => "Original Guy",
      :email   => "original.guy@email.com",
    })
    @user.add_api_key!({ :key_type => "primary" })
    @id = @user.id
    @fake_id = get_fake_mongo_object_id
    @user_count = User.count
  end
  
  # - - - - - - - - - -
  
  shared "unchanged email in database" do
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @user.email
    end
  end

  # - - - - - - - - - -
  
  context "anonymous user : put /users" do
    before do
      put "/users/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged user count"
  end
  
  context "incorrect user : put /users" do
    before do
      put "/users/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged user count"
  end
  
  context "normal user : put /users" do
    before do
      put "/users/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end
  
  # - - - - - - - - - -
  
  context "admin user : put /users : create : protected param 'admin'" do
    before do
      put "/users/#{@fake_id}", {
        :api_key   => @admin_user.primary_api_key,
        :name      => "New Guy",
        :email     => "new.guy@email.com",
        :admin     => true
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
    use "unchanged email in database"
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @user.name
    end
  end

  context "admin user : put /users : create : extra param 'junk'" do
    before do
      put "/users/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :junk    => "This is an extra parameter (junk)"
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
    use "unchanged email in database"
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @user.name
    end
  end
  
  # - - - - - - - - - -
  
  context "admin user : put /users : update : protected param 'admin'" do
    before do
      put "/users/#{@id}", {
        :api_key   => @admin_user.primary_api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :admin     => true
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged user count"
    use "unchanged email in database"
  
    test "body should say 'admin' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "admin", parsed_response_body["errors"]["invalid_params"]
    end
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @user.name
    end
  end
  
  context "admin user : put /users : update : extra param 'junk'" do
    before do
      put "/users/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged user count"
    use "unchanged email in database"

    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @user.name
    end
  end
  
  # - - - - - - - - - -
  
  context "admin user : put /users : create : correct params" do
    before do
      put "/users/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
    use "unchanged email in database"
    
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @user.name
    end
  end

  # - - - - - - - - - -

  context "admin user : put /users : update : correct params" do
    before do
      put "/users/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged user count"
    
    test "name should be updated in database" do
      user = User.find_by_id(@id)
      assert_equal "New Guy", user.name
    end
      
    test "email should be updated in database" do
      user = User.find_by_id(@id)
      assert_equal "new.guy@email.com", user.email
    end

    test "body should have API key, 40 characters long" do
      assert_equal 40, parsed_response_body["primary_api_key"].length
    end
    
    test "body should have API key different from admin key" do
      assert_not_equal @admin_user.primary_api_key, parsed_response_body["primary_api_key"]
    end
  end

end

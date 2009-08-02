require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PutUsersControllerTest < RequestTestCase

  def setup_for_update
    @original_user = User.create({
      :name    => "Original Guy",
      :email   => "original.guy@email.com",
      :purpose => "User account for Web application"
    })
    @id = @original_user.id
    @fake_id = get_fake_mongo_object_id
    @user_count = User.count
  end
  
  context "anonymous user : put /users" do
    before :all do
      setup_for_update
      put "/users/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged user count"
  end
  
  context "incorrect user : put /users" do
    before :all do
      setup_for_update
      put "/users/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged user count"
  end
  
  context "unconfirmed user : put /users" do
    before :all do
      setup_for_update
      put "/users/#{@id}", :api_key => @unconfirmed_user.api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end
  
  context "confirmed user : put /users" do
    before :all do
      setup_for_update
      put "/users/#{@id}", :api_key => @confirmed_user.api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end
  
  context "admin user : put /users : create : correct params" do
    before :all do
      setup_for_update
      put "/users/#{@fake_id}", {
        :api_key => @admin_user.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application"
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
    
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @original_user.name
    end
      
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @original_user.email
    end
  end

  context "admin user : put /users : create : protected param" do
    before :all do
      setup_for_update
      put "/users/#{@fake_id}", {
        :api_key   => @admin_user.api_key,
        :name      => "New Guy",
        :email     => "new.guy@email.com",
        :purpose   => "User account for Web application",
        :confirmed => "true"
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @original_user.name
    end
      
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @original_user.email
    end
  end

  context "admin user : put /users : create : extra params" do
    before :all do
      setup_for_update
      put "/users/#{@fake_id}", {
        :api_key => @admin_user.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application",
        :extra   => "This is an extra parameter (junk)"
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @original_user.name
    end
      
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @original_user.email
    end
  end

  context "admin user : put /users : update : correct params" do
    before :all do
      setup_for_update
      put "/users/#{@id}", {
        :api_key => @admin_user.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application"
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
  end
  
  context "admin user : put /users : update : protected param" do
    before :all do
      setup_for_update
      put "/users/#{@id}", {
        :api_key   => @admin_user.api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :purpose   => "User account for Web application",
        :confirmed => "true"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged user count"
  
    test "body should say confirm is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "confirmed", parsed_response_body["errors"]["invalid_params"]
    end
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @original_user.name
    end
      
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @original_user.email
    end
  end
  
  context "admin user : put /users : update : extra param" do
    before :all do
      setup_for_update
      put "/users/#{@id}", {
        :api_key => @admin_user.api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :purpose => "User account for Web application",
        :extra   => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged user count"

    test "body should say extra is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "extra", parsed_response_body["errors"]["invalid_params"]
    end
  
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @original_user.name
    end
      
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @original_user.email
    end
  end

end

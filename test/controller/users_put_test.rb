require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PutUsersControllerTest < RequestTestCase

  before :all do
    reset_users
    @admin       = create_admin_user
    @confirmed   = create_confirmed_user
    @unconfirmed = create_unconfirmed_user
  end
  
  context "anonymous user : put /users" do
    doing {
      put '/users/2020'
    }.should_give MissingApiKey
  end
  
  context "incorrect user : put /users" do
    doing {
      put '/users/2020', :api_key => "does_not_exist_in_database"
    }.should_give InvalidApiKey
  end
  
  context "unconfirmed user : put /users" do
    doing {
      put '/users/2020', :api_key => @unconfirmed.api_key
    }.should_give UnauthorizedApiKey
  end
  
  context "confirmed user : put /users" do
    doing {
      put '/users/2020', :api_key => @confirmed.api_key
    }.should_give UnauthorizedApiKey
  end
  
  context "admin user : put /users with correct params to create" do
    before :all do
      @user_count = User.count
      put '/users/2020', {
        :api_key => @admin.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application",
      }
    end
    
    should_give Status201
    should_give TimestampsAndId
  
    test "should increment user count" do
      assert_equal @user_count + 1, User.count
    end
    
    test "name should be correct in database" do
      user = User.find_by_id("2020")
      assert_equal "New Guy", user.name
    end
      
    test "email should be correct in database" do
      user = User.find_by_id("2020")
      assert_equal "new.guy@email.com", user.email
    end
  end

  context "admin user : put /users with correct params to update" do
    before :all do
      User.create({
        :_id     => "2020",
        :name    => "Original Guy",
        :email   => "original.guy@email.com",
        :purpose => "User account for Web application"
      })
      @user_count = User.count
      put '/users/2020', {
        :api_key => @admin.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application"
      }
    end
    
    should_give Status200
    should_give TimestampsAndId
  
    test "should not change user count" do
      assert_equal @user_count, User.count
    end
    
    test "name should be correct in database" do
      user = User.find(parsed_response_body["_id"])
      assert_equal "New Guy", user.name
    end
      
    test "email should be correct in database" do
      user = User.find(parsed_response_body["_id"])
      assert_equal "new.guy@email.com", user.email
    end
  end

  context "admin user : put /users with protected param" do
    before :all do
      put '/users/2020', {
        :api_key   => @admin.api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :purpose   => "User account for Web application",
        :confirmed => "true"
      }
    end

    should_give Status400
  
    test "body should explain the problem" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "confirmed", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin user : put /users with extra param" do
    before :all do
      put '/users/2020', {
        :api_key   => @admin.api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :purpose => "User account for Web application",
        :junk    => "This is junk"
      }
    end
  
    should_give Status400
  
    test "body should explain the problem" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end

end

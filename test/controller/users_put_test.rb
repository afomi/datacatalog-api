require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PutUsersControllerTest < RequestTestCase

  context "anonymous user : put /users" do
    before :all do
      @user_count = User.count
      put '/users/2020'
    end

    should_give MissingApiKey
    should_give UnchangedUserCount
  end
  
  context "incorrect user : put /users" do
    before :all do
      @user_count = User.count
      put '/users/2020', :api_key => "does_not_exist_in_database"
    end

    should_give InvalidApiKey
    should_give UnchangedUserCount
  end
  
  context "unconfirmed user : put /users" do
    before :all do
      @user_count = User.count
      put '/users/2020', :api_key => @unconfirmed_user.api_key
    end

    should_give UnauthorizedApiKey
    should_give UnchangedUserCount
  end
  
  context "confirmed user : put /users" do
    before :all do
      @user_count = User.count
      put '/users/2020', :api_key => @confirmed_user.api_key
    end

    should_give UnauthorizedApiKey
    should_give UnchangedUserCount
  end
  
  context "admin user : put /users : create : correct params" do
    before :all do
      @user_count = User.count
      put '/users/2020', {
        :api_key => @admin_user.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application"
      }
    end
    
    should_give Status201
    should_give TimestampsAndId
    should_give IncrementedUserCount
    
    test "name should be correct in database" do
      user = User.find_by_id("2020")
      assert_equal "New Guy", user.name
    end
      
    test "email should be correct in database" do
      user = User.find_by_id("2020")
      assert_equal "new.guy@email.com", user.email
    end
  end

  context "admin user : put /users : create : protected param" do
    before :all do
      @user_count = User.count
      put '/users/2020', {
        :api_key   => @admin_user.api_key,
        :name      => "New Guy",
        :email     => "new.guy@email.com",
        :purpose   => "User account for Web application",
        :confirmed => "true"
      }
    end
    
    should_give Status400
    should_give UnchangedUserCount
  
    test "body should that confirmed is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "confirmed", parsed_response_body["errors"]["invalid_params"]
    end
  end

  context "admin user : put /users : create : extra params" do
    before :all do
      @user_count = User.count
      put '/users/2020', {
        :api_key => @admin_user.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application",
        :junk    => "This is junk"
      }
    end
    
    should_give Status400
    should_give UnchangedUserCount
  
    test "body should that junk is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  def create_original_guy_user
    User.create({
      :_id     => "2020",
      :name    => "Original Guy",
      :email   => "original.guy@email.com",
      :purpose => "User account for Web application"
    })
  end

  context "admin user : put /users : update : correct params" do
    before :all do
      create_original_guy_user
      @user_count = User.count
      put '/users/2020', {
        :api_key => @admin_user.api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :purpose => "User account for Web application"
      }
    end
    
    should_give Status200
    should_give TimestampsAndId
    should_give UnchangedUserCount
    
    test "name should be updated in database" do
      user = User.find_by_id("2020")
      assert_equal "New Guy", user.name
    end
      
    test "email should be updated in database" do
      user = User.find_by_id("2020")
      assert_equal "new.guy@email.com", user.email
    end
  end

  context "admin user : put /users : update : protected param" do
    before :all do
      create_original_guy_user
      @user_count = User.count
      put '/users/2020', {
        :api_key   => @admin_user.api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :purpose   => "User account for Web application",
        :confirmed => "true"
      }
    end

    should_give Status400
    should_give UnchangedUserCount
  
    test "body should that confirm is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "confirmed", parsed_response_body["errors"]["invalid_params"]
    end

    test "name should be unchanged in database" do
      user = User.find_by_id("2020")
      assert_equal "Original Guy", user.name
    end
      
    test "email should be unchanged in database" do
      user = User.find_by_id("2020")
      assert_equal "original.guy@email.com", user.email
    end
  end
  
  context "admin user : put /users : update : extra param" do
    before :all do
      create_original_guy_user
      @user_count = User.count
      put '/users/2020', {
        :api_key => @admin_user.api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :purpose => "User account for Web application",
        :junk    => "This is junk"
      }
    end
  
    should_give Status400
    should_give UnchangedUserCount
  
    test "body should that junk is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end

    test "name should be unchanged in database" do
      user = User.find_by_id("2020")
      assert_equal "Original Guy", user.name
    end
      
    test "email should be unchanged in database" do
      user = User.find_by_id("2020")
      assert_equal "original.guy@email.com", user.email
    end
  end

end

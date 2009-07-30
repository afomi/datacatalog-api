require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class DeleteUsersControllerTest < RequestTestCase

  before :all do
    reset_users
    @admin       = create_admin_user
    @confirmed   = create_confirmed_user
    @unconfirmed = create_unconfirmed_user
    User.create({
      :_id     => "51515",
      :name    => "Will Not-Last-Long",
      :email   => "will.not.last.long@email.com",
      :purpose => "User account for Web application"
    })
    @user_count = User.count
  end
  
  context "anonymous user : delete /users" do
    doing {
      delete '/users/51515'
    }.should_give MissingApiKey

    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "incorrect user : delete /users" do
    doing {
      delete '/users/51515', :api_key => "does_not_exist_in_database"
    }.should_give InvalidApiKey

    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "unconfirmed user : delete /users" do
    doing {
      delete '/users/51515', :api_key => @unconfirmed.api_key
    }.should_give UnauthorizedApiKey

    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "confirmed user : delete /users" do
    doing {
      delete '/users/51515', :api_key => @confirmed.api_key
    }.should_give UnauthorizedApiKey

    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "admin user : delete /users" do
    doing {
      delete '/users/51515', :api_key => @admin.api_key
    }
    
    should_give Status200

    test "body should have correct name value" do
      assert_include "_id", parsed_response_body
      assert_equal "51515", parsed_response_body["_id"]
    end
    
    test "should decrement user count" do
      assert_equal @user_count - 1, User.count
    end
  end

end

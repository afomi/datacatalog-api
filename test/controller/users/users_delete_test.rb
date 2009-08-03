require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class UsersDeleteControllerTest < RequestTestCase

  def setup_for_deletion
    user = User.create({
      :name    => "Will Not-Last-Long",
      :email   => "will.not.last.long@email.com",
      :purpose => "User account for Web application"
    })
    @id = user.id
    @user_count = User.count
  end
  
  context "anonymous user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged user count"
  end
  
  context "incorrect user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged user count"
  end
  
  context "unconfirmed user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => @unconfirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end
  
  context "confirmed user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => @confirmed_user.api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end
  
  context "admin user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => @admin_user.api_key
    end
    
    use "return 200 Ok"
    use "decremented user count"
  
    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end
    
    test "user should be deleted in database" do
      assert_equal nil, User.find_by_id(@id)
    end
  end

  context "admin user : double delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => @admin_user.api_key
      delete "/users/#{@id}", :api_key => @admin_user.api_key
    end
    
    use "return 404 Not Found"
    use "decremented user count"
    use "return an empty response body"
  
    test "user should be deleted in database" do
      assert_equal nil, User.find_by_id(@id)
    end
  end

end

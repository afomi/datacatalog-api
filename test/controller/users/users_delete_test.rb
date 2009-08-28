require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersDeleteControllerTest < RequestTestCase

  before do
    user = User.create({
      :name    => "Will Not-Last-Long",
      :email   => "will.not.last.long@email.com",
    })
    @id = user.id
    @user_count = User.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -
  
  context "anonymous : delete /users/:id" do
    before do
      delete "/users/#{@id}"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged user count"
  end
  
  context "incorrect API key : delete /users/:id" do
    before do
      delete "/users/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged user count"
  end
  
  context "normal API key : delete /users/:id" do
    before do
      delete "/users/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /users/:fake_id" do
    before do
      delete "/users/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "unchanged user count"
    use "return an empty response body"
  end

  # - - - - - - - - - -

  context "admin API key : delete /users/:id" do
    before do
      delete "/users/#{@id}", :api_key => @admin_user.primary_api_key
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
  
  # - - - - - - - - - -

  context "admin API key : double delete /users/:id" do
    before do
      delete "/users/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/users/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "decremented user count"
    use "return an empty response body"
  
    test "user should be deleted in database" do
      assert_equal nil, User.find_by_id(@id)
    end
  end

end

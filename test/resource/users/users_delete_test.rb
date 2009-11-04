require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersDeleteTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user(:name => "Original User")
    @user.add_api_key!({ :key_type => "primary" })
    @user_count = User.count
  end
  
  shared "attempted DELETE user with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
  end

  shared "successful DELETE user with :id" do
    use "return 204 No Content"
    use "decremented user count"

    test "user should be deleted in database" do
      assert_equal nil, User.find_by_id(@user.id)
    end
  end

  context "curator API key : delete /:id" do
    before do
      delete "/#{@user.id}", :api_key => @curator_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end

  context "owner API key : delete /:id" do
    before do
      delete "/#{@user.id}", :api_key => @user.primary_api_key
    end
    
    use "successful DELETE user with :id"
  end

  context "admin API key : delete /:id" do
    before do
      delete "/#{@user.id}", :api_key => @admin_user.primary_api_key
    end
    
    use "successful DELETE user with :id"
  end

end

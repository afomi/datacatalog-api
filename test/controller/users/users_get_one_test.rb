require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user_with_primary_key
  end
  
  after do
    @user.destroy
  end

  shared "successful GET user with :id" do
    use "return 200 Ok"
  
    test "body should have correct text" do
      assert_equal "Data Mangler", parsed_response_body["name"]
    end
  end

  context "non owner API key : get /:id" do
    before do
      get "/#{@user.id}", :api_key => @normal_user.primary_api_key
    end

    use "successful GET user with :id"
    
    doc_properties %w(name id created_at updated_at)
  end

  context "owner API key : get /:id" do
    before do
      get "/#{@user.id}", :api_key => @user.primary_api_key
    end
  
    use "successful GET user with :id"
    
    doc_properties %w(name id created_at updated_at
      email primary_api_key application_api_keys valet_api_keys
      curator admin)
  end

end

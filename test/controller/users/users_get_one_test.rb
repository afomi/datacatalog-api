require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @owner_user = create_user_with_primary_key
    @id = @owner_user.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "attempted GET user with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
  end

  shared "successful GET user with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Data Mangler", parsed_response_body["name"]
    end
  end

  # - - - - - - - - - -

  context "anonymous : get /:id" do
    before do
      get "/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /:id" do
    before do
      get "/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "non owner API key : get /:fake_id" do
    before do
      get "/#{@fake_id}", :api_key => @normal_user.primary_api_key
    end

    use "attempted GET user with :fake_id"
  end

  %w(normal admin).each do |role|
    context "#{role} API key : get /:fake_id" do
      before do
        get "/#{@fake_id}", :api_key => primary_api_key_for(role)
      end
  
      use "attempted GET user with :fake_id"
    end
  end
  
  context "non owner API key : get /:id" do
    before do
      get "/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "successful GET user with :id"

    test "body should be sanitized" do
      assert_not_include "primary_api_key", parsed_response_body
      assert_not_include "application_api_keys", parsed_response_body
      assert_not_include "valet_api_keys", parsed_response_body
      assert_not_include "curator", parsed_response_body
      assert_not_include "admin", parsed_response_body
      assert_not_include "email", parsed_response_body
    end
  end

  %w(owner admin).each do |role|
    context "normal API key : get /:id" do
      before do
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end
  
      use "successful GET user with :id"

      test "body should be complete" do
        assert_include "primary_api_key", parsed_response_body
        assert_include "application_api_keys", parsed_response_body
        assert_include "valet_api_keys", parsed_response_body
        assert_include "curator", parsed_response_body
        assert_include "admin", parsed_response_body
        assert_include "email", parsed_response_body
      end
    end
  end

end

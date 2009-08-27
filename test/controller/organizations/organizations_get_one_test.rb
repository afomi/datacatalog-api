require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsGetOneControllerTest < RequestTestCase

  before do
    organization = Organization.create :text => "Organization A"
    @id = organization.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous user : get /organizations/:id" do
    before do
      get "/organizations/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /organizations/:id" do
    before do
      get "/organizations/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end

  # - - - - - - - - - -
  
  context "normal user : get /organizations/:fake_id : not found" do
    before do
      get "/organizations/#{@fake_id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin user : get /organizations/:fake_id : not found" do
    before do
      get "/organizations/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  # - - - - - - - - - -

  context "normal user : get /organizations/:id : found" do
    before do
      get "/organizations/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Organization A", parsed_response_body["text"]
    end
  end
  
  context "admin user : get /organizations/:id : found" do
    before do
      get "/organizations/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Organization A", parsed_response_body["text"]
    end
  end

end

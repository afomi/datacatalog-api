require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Organizations end

  before do
    organization = Organization.create(:name => "Original Organization")
    @id = organization.id
    @organization_count = Organization.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "attempted DELETE organization with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
  end

  shared "successful DELETE organization with :id" do
    use "return 200 Ok"
    use "decremented organization count"

    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end

    test "organization should be deleted in database" do
      assert_equal nil, Organization.find_by_id(@id)
    end
  end

  shared "attempted double DELETE organization with :id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented organization count"

    test "should be deleted in database" do
      assert_equal nil, Organization.find_by_id(@id)
    end
  end

  # - - - - - - - - - -

  context "anonymous : delete /" do
    before do
      delete "/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged organization count"
  end

  context "incorrect API key : delete /" do
    before do
      delete "/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged organization count"
  end

  context "normal API key : delete /" do
    before do
      delete "/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged organization count"
  end

  # - - - - - - - - - -

  context "curator API key : delete /:fake_id" do
    before do
      delete "/#{@fake_id}", :api_key => @curator_user.primary_api_key
    end
    
    use "attempted DELETE organization with :fake_id"
  end

  context "admin API key : delete /:fake_id" do
    before do
      delete "/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "attempted DELETE organization with :fake_id"
  end

  # - - - - - - - - - -

  context "curator API key : delete /:id" do
    before do
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "successful DELETE organization with :id"
  end
  
  context "admin API key : delete /:id" do
    before do
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "successful DELETE organization with :id"
  end

  # - - - - - - - - - -

  context "admin API key : double delete /users" do
    before do
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "attempted double DELETE organization with :id"
  end

  context "admin API key : double delete /users" do
    before do
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "attempted double DELETE organization with :id"
  end

end

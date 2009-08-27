require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsDeleteControllerTest < RequestTestCase

  before do
    organization = Organization.create :text => "Original Organization"
    @id = organization.id
    @organization_count = Organization.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous user : delete /organizations" do
    before do
      delete "/organizations/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged organization count"
  end

  context "incorrect user : delete /organizations" do
    before do
      delete "/organizations/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged organization count"
  end

  context "normal user : delete /organizations" do
    before do
      delete "/organizations/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged organization count"
  end

  # - - - - - - - - - -

  context "admin user : delete /organizations/:fake_id" do
    before do
      delete "/organizations/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
  end

  # - - - - - - - - - -

  context "admin user : delete /organizations/:id" do
    before do
      delete "/organizations/#{@id}", :api_key => @admin_user.primary_api_key
    end

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

  context "admin user : double delete /users" do
    before do
      delete "/organizations/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/organizations/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented organization count"
  
    test "organization should be deleted in database" do
      assert_equal nil, Organization.find_by_id(@id)
    end
  end

end

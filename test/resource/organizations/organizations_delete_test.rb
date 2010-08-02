require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class OrganizationsDeleteTest < RequestTestCase

  def app; DataCatalog::Organizations end

  before do
    @organization = create_organization(
      :name => "Original Organization"
    )
    @organization_count = Organization.count
  end

  context "basic API key : delete /:id" do
    before do
      delete "/#{@organization.id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged organization count"
  end

  context "curator API key : delete /:id" do
    before do
      delete "/#{@organization.id}", :api_key => @curator_user.primary_api_key
    end

    use "return 204 No Content"
    use "decremented organization count"

    test "organization should be deleted in database" do
      assert_equal nil, Organization.find_by_id(@id)
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class OrganizationsPutControllerTest < RequestTestCase

  def app; DataCatalog::Organizations end

  before do
    @user = create_user_with_primary_key
    @organization = create_organization(
      :name     => "Original Organization",
      :org_type => "governmental",
      :user_id  => @user.id
    )
    @organization_count = Organization.count
  end
  
  after do
    @organization.destroy
    @user.destroy
  end

  shared "unchanged organization name in database" do
    test "name should be unchanged in database" do
      assert_equal "Original Organization", @organization.name
    end
  end
  
  context "basic API key : put /:id" do
    before do
      put "/#{@organization.id}",
        :api_key => @normal_user.primary_api_key,
        :name    => "New Organization"
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged organization name in database"
  end

  context "owner API key : put /:id" do
    before do
      put "/#{@organization.id}",
        :api_key => @normal_user.primary_api_key,
        :name    => "New Organization"
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged organization name in database"
  end
  
  context "curator API key : put /:id" do
    before do
      put "/#{@organization.id}",
        :api_key => @curator_user.primary_api_key,
        :name    => "New Organization"
    end
    
    use "return 200 Ok"
    use "unchanged organization count"
  
    test "name should be updated in database" do
      organization = Organization.find_by_id!(@organization.id)
      assert_equal "New Organization", organization.name
    end
  end

end

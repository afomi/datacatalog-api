require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class OrganizationsGetOneTest < RequestTestCase

  def app; DataCatalog::Organizations end

  before do
    @user = create_user_with_primary_key
    @organization = create_organization(
      :name      => "Organization A",
      :user_id   => @user.id
    )
  end
  
  after do
    @organization.destroy
    @user.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@organization.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct values" do
      assert_equal "Organization A", parsed_response_body["name"]
      assert_equal @user.id, parsed_response_body["user_id"]
    end
    
    doc_properties %w(
      name
      acronym
      org_type
      description
      slug
      url
      user_id
      custom
      raw
      id
      created_at
      updated_at
    )

  end

end

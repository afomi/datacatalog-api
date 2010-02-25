require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class OrganizationsGetOneTest < RequestTestCase

  def app; DataCatalog::Organizations end

  before do
    @user = create_user_with_primary_key
    @jurisdiction = create_jurisdiction(
      :name     => "Jurisdiction A",
      :user_id  => @user.id
    )
    @organization = create_organization(
      :name      => "Organization A",
      :jurisdiction_id => @jurisdiction.id,
      :user_id   => @user.id
    )
  end
  
  after do
    @organization.destroy
    @jurisdiction.destroy
    @user.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@organization.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct values" do
      assert_equal "Organization A", parsed_response_body["name"]
      assert_equal @user.id.to_s, parsed_response_body["user_id"]
    end
    
    doc_properties %w(
      name
      names
      acronym
      org_type
      description
      slug
      url
      interest
      level
      source_count
      custom
      raw
      id
      jurisdiction
      jurisdiction_id
      created_at
      updated_at
      user_id
    )

  end

end

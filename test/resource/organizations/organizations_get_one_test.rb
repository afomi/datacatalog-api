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
      actual = parsed_response_body
      assert_equal "Organization A", actual["name"]
      assert_equal @user.id.to_s, actual["user_id"]
    end

    context "with parentage" do
      before do
        @jurisdiction = create_organization(
            :name      => "US Federal Government",
            :org_type  => "governmental",
            :top_level => true
        )
        @organization.parent_id = @jurisdiction.id
        @organization.save!
        get "/#{@organization.id}", :api_key => @normal_user.primary_api_key
      end

      test "parent_id should be set" do
        assert_equal parsed_response_body['parent_id'], @jurisdiction.id.to_s
      end

      test "parent should be correct" do
        actual = parsed_response_body['parent']
        assert_properties %w(href name slug), actual
        assert_equal actual["href"], "/organizations/#{@jurisdiction.id}"
        assert_equal actual["name"], "US Federal Government"
        assert_equal actual["slug"], "us-federal-government"
      end

      test "top_parent should be correct" do
        actual = parsed_response_body['top_parent']
        assert_properties %w(href name slug), actual
        assert_equal actual["href"], "/organizations/#{@jurisdiction.id}"
        assert_equal actual["name"], "US Federal Government"
        assert_equal actual["slug"], "us-federal-government"
      end
    end

    doc_properties %w(
      name
      names
      acronym
      org_type
      description
      parent
      parent_id
      top_parent
      children
      slug
      url
      home_url
      catalog_name
      catalog_url
      interest
      top_level
      source_count
      user_id
      custom
      id
      created_at
      updated_at
    )

  end

end

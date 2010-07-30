require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class OrganizationsGetAllTest < RequestTestCase

  def app; DataCatalog::Organizations end

  context "0 organizations" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 organizations" do
    before do
      @organizations = 3.times.map do |i|
        create_organization(
          :name      => "Organization #{i}",
          :user_id   => @normal_user.id
        )
      end
    end
    
    after do
      @organizations.each { |x| x.destroy }
    end
    
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct name" do
        actual = (0 ... 3).map { |n| @members[n]["name"] }
        3.times { |n| assert_include "Organization #{n}", actual }
      end
      
      members_properties %w(
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
        custom
        raw
        id
        created_at
        updated_at
        user_id
      )
    end
  end

end

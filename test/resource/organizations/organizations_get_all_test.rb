require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class OrganizationsGetAllTest < RequestTestCase

  def app; DataCatalog::Organizations end

  context "0 organizations" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "return 200 Ok"
      use "return an empty list response body"
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
      end

      test "body should have 3 top level elements" do
        assert_equal 3, parsed_response_body.length
      end

      test "body should have correct name" do
        actual = (0 ... 3).map { |n| parsed_response_body[n]["name"] }
        3.times { |n| assert_include "Organization #{n}", actual }
      end
      
      docs_properties %w(
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

end

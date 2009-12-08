require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class OrganizationsGetSearchTest < RequestTestCase

  include DataCatalog

  def app; Organizations end

  before do
    Organization.destroy_all unless Organization.count == 0
    @organizations = [
      create_organization({
        :name        => "Environmental Protection Agency",
        :acronym     => "EPA",
        :names       => ["Environmental Protection Agency"],
        :description => "The mission of EPA is to protect human health and to safeguard the natural environment -- air, water and land -- upon which life depends.",
      }),
      create_organization({
        :name        => "Department of Justice",
        :acronym     => "DOJ",
        :names       => [
          "Department of Justice",
          "Justice, Department of"
        ],
        :description => "To enforce the law and defend the interests of the United States according to the law; to ensure public safety against threats foreign and domestic; to provide federal leadership in preventing and controlling crime; to seek just punishment for those guilty of unlawful behavior; and to ensure fair and impartial administration of justice for all Americans.",
      }),
      create_organization({
        :name        => "Department of Health and Human Services",
        :acronym     => "HHS",
        :names       => [
          "Department of Health and Human Services",
          "Dept. of Health and Human Services"
        ],
        :description => "The Department of Health and Human Services (HHS) is the United States government's principal agency for protecting the health of all Americans and providing essential human services, especially for those who are least able to help themselves.",
      }),
    ]
  end

  after do
    @organizations.each { |x| x.destroy } if @organizations
  end
  
  context "search=defend" do
    before do
      @search_params = { :search => "defend" }
    end
  
    %w(normal).each do |role|
      context "#{role} : get /" do
        before do
          get "/", @search_params.merge(:api_key => primary_api_key_for(role))
          @members = parsed_response_body['members']
        end

        use "return 200 Ok"

        test "body should have 1 organization" do
          assert_equal 1, @members.length
        end
      
        test "body should have correct organization" do
          assert_equal %{Department of Justice},
            @members[0]['name']
        end
      
        members_properties %w(
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
  
  context "search=health" do
    before do
      @search_params = { :search => "health" }
    end
  
    %w(normal).each do |role|
      context "#{role} : get /" do
        before do
          get "/", @search_params.merge(:api_key => primary_api_key_for(role))
          @members = parsed_response_body['members']
        end

        use "return 200 Ok"
      
        test "body should have correct organizations" do
          names = @members.map { |x| x['name'] }
          assert_equal 2, names.length
          assert_include %{Environmental Protection Agency}, names
          assert_include %{Department of Health and Human Services}, names
        end
      end
    end
  end

end

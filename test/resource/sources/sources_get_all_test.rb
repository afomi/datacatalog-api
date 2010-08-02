require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourcesGetAllTest < RequestTestCase

  def app; DataCatalog::Sources end

  shared "successful GET of 0 sources" do
    use "return 200 Ok"
    use "return an empty list of members"
  end

  shared "successful GET of 3 sources" do
    test "body should have 3 top level elements" do
      assert_equal 3, @members.length
    end

    test "body should have correct text" do
      actual = (0 ... 3).map { |n| @members[n]["url"] }
      3.times { |n| assert_include "http://data.gov/sources/#{n}", actual }
    end

    members_properties %w(
      catalog_name
      catalog_url
      categories
      comments
      created_at
      custom
      description
      documentation_url
      documents
      downloads
      favorite_count
      frequency
      id
      license
      license_url
      notes
      organization
      organization_id
      jurisdiction
      jurisdiction_id
      period_end
      period_start
      ratings
      rating_stats
      raw
      released
      slug
      source_type
      title
      updated_at
      updates_per_year
      url
    )
  end

  context "0 sources" do
    %w(normal).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
          @members = parsed_response_body['members']
        end

        use "successful GET of 0 sources"
      end
    end
  end

  context "3 sources" do
    before do
      @sources = 3.times.map do |n|
        create_source(
          :title => "Source #{n}", 
          :url   => "http://data.gov/sources/#{n}",
          :slug  => "source-#{n}",
          :source_type  => "dataset"
        )
      end
    end

    after do
      @sources.each { |s| s.destroy }
    end

    %w(normal).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
          @members = parsed_response_body['members']
        end

        use "successful GET of 3 sources"
      end
    end
  end

end

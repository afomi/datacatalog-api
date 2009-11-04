require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourcesPostControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    @source_count = Source.count
    @valid_params = {
      :title       => "Just a data source",
      :url         => "http://data.gov/original",
      :source_type => "dataset",
    }
  end

  shared "successful POST to sources" do
    use "return 201 Created"
    use "incremented source count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/sources/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct url" do
      assert_equal "http://data.gov/original", parsed_response_body["url"]
    end
    
    test "text should be correct in database" do
      source = Source.find_by_id!(parsed_response_body["id"])
      assert_equal "http://data.gov/original", source.url
    end
    
    doc_properties %w(
      catalog_name
      catalog_url
      categories
      comments
      created_at
      custom
      description
      documentation_url
      documents
      frequency
      id
      license
      license_url
      notes
      organization
      organization_id
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

  %w(curator).each do |role|
    context "#{role} API key : post / with 1 custom field" do
      before do
        post "/", @valid_params.merge({
          :api_key                 => primary_api_key_for(role),
          "custom[0][label]"       => "custom 1",
          "custom[0][description]" => "description 1",
          "custom[0][type]"        => "string",
          "custom[0][value]"       => "HR-57",
        })
      end

      use "successful POST to sources"

      test "custom field should be correct in database" do
        source = Source.find_by_id!(parsed_response_body["id"])
        assert_equal "custom 1",      source.custom["0"]["label"]
        assert_equal "description 1", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end
    end
    
    context "#{role} API key : post / with 2 custom fields" do
      before do
        post "/", @valid_params.merge({
          :api_key                 => primary_api_key_for(role),
          "custom[0][label]"       => "custom 1",
          "custom[0][description]" => "description 1",
          "custom[0][type]"        => "string",
          "custom[0][value]"       => "HR-57",
          "custom[1][label]"       => "custom 2",
          "custom[1][description]" => "description 2",
          "custom[1][type]"        => "integer",
          "custom[1][value]"       => "805"
        })
      end
    
      use "successful POST to sources"
    
      test "custom field 1 should be correct in database" do
        source = Source.find_by_id!(parsed_response_body["id"])
        assert_equal "custom 1",      source.custom["0"]["label"]
        assert_equal "description 1", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end
    
      test "custom field 2 should be correct in database" do
        source = Source.find_by_id!(parsed_response_body["id"])
        assert_equal "custom 2",      source.custom["1"]["label"]
        assert_equal "description 2", source.custom["1"]["description"]
        assert_equal "integer",       source.custom["1"]["type"]
        assert_equal "805",           source.custom["1"]["value"]
      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesPostControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    @source_count = Source.count
  end

  shared "successful POST to sources" do
    use "return 201 Created"
    use "return timestamps and id in body" 
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
      source = Source.find_by_id(parsed_response_body["id"])
      assert_equal "http://data.gov/original", source.url
    end

    test "body should have correct attributes" do
      assert_include "title"              , parsed_response_body
      assert_include "slug"               , parsed_response_body
      assert_include "description"        , parsed_response_body
      assert_include "type"               , parsed_response_body
      assert_include "license"            , parsed_response_body
      assert_include "catalog_name"       , parsed_response_body
      assert_include "url"                , parsed_response_body
      assert_include "documentation_url"  , parsed_response_body
      assert_include "license_url"        , parsed_response_body
      assert_include "catalog_url"        , parsed_response_body  
      assert_include "released",     parsed_response_body
      assert_include "period_start", parsed_response_body
      assert_include "period_end",   parsed_response_body
      assert_include "rating_stats", parsed_response_body
      rating_stats = parsed_response_body["rating_stats"]
      assert_include "count",        rating_stats
      assert_include "average",      rating_stats
      assert_include "total",        rating_stats
    end

  end

  context "post /" do
    context "anonymous" do
      before do
        post "/"
      end

      use "return 401 because the API key is missing"
      use "unchanged source count"
    end

    context "incorrect API key" do
      before do
        post "/", :api_key => "does_not_exist_in_database"
      end

      use "return 401 because the API key is invalid"
      use "unchanged source count"
    end

    context "normal API key" do
      before do
        post "/", :api_key => @normal_user.primary_api_key
      end

      use "return 401 because the API key is unauthorized"
      use "unchanged source count"
    end
  end

  %w(curator admin).each do |role|
    context "#{role} API key : post / with protected param" do
      before do
        post "/", {
          :api_key    => primary_api_key_for(role),
          :title      => "Just a data source",
          :url        => "http://data.gov/original",
          :updated_at => Time.now.to_json
        }
      end
      
      use "return 400 Bad Request"
      use "unchanged source count"
      use "return errors hash saying updated_at is invalid"
    end

    context "#{role} API key : post / with invalid param" do
      before do
        post "/", {
          :api_key => primary_api_key_for(role),
          :title   => "Just a data source",
          :url     => "http://data.gov/original",
          :junk    => "This is an extra param (junk)"
        }
      end
      
      use "return 400 Bad Request"
      use "unchanged source count"
      use "return errors hash saying junk is invalid"
    end

    context "#{role} API key : post / without title" do
      before do
        post "/", {
          :api_key => primary_api_key_for(role),
          :url     => "http://data.gov/original"
        }
      end
    
      use "return 400 Bad Request"
      use "unchanged source count"
      use "return errors hash saying title is missing"
    end
    
    context "#{role} API key : post / without url" do
      before do
        post "/", {
          :api_key => primary_api_key_for(role),
          :title   => "Just a data source",
        }
      end
    
      use "return 400 Bad Request"
      use "unchanged source count"
      use "return errors hash saying url is missing"
    end
    
    context "#{role} API key : post / with invalid url" do
      before do
        post "/", {
          :api_key => primary_api_key_for(role),
          :title   => "Just a data source",
          :url     => "https://secret.com/13"
        }
      end
    
      use "return 400 Bad Request"
      use "unchanged source count"
      use "return errors hash saying url scheme is incorrect"
    end
      
    context "#{role} API key : post / with correct params" do
      before do
        post "/", {
          :api_key => primary_api_key_for(role),
          :title   => "Just a data source",
          :url     => "http://data.gov/original"
        }
      end
    
      use "successful POST to sources"
    end

    context "#{role} API key : post / with 1 custom field" do
      before do
        post "/", {
          :api_key                 => primary_api_key_for(role),
          :title                   => "Just a data source",
          :url                     => "http://data.gov/original",
          "custom[0][label]"       => "custom 1",
          "custom[0][description]" => "description 1",
          "custom[0][type]"        => "string",
          "custom[0][value]"       => "HR-57"
        }
      end

      use "successful POST to sources"

      test "custom field should be correct in database" do
        source = Source.find_by_id(parsed_response_body["id"])
        assert_equal "custom 1",      source.custom["0"]["label"]
        assert_equal "description 1", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end
    end
    
    context "#{role} API key : post / with 2 custom fields" do
      before do
        post "/", {
          :api_key                 => primary_api_key_for(role),
          :title                   => "Just a data source",
          :url                     => "http://data.gov/original",
          "custom[0][label]"       => "custom 1",
          "custom[0][description]" => "description 1",
          "custom[0][type]"        => "string",
          "custom[0][value]"       => "HR-57",
          "custom[1][label]"       => "custom 2",
          "custom[1][description]" => "description 2",
          "custom[1][type]"        => "integer",
          "custom[1][value]"       => "805"
        }
      end

      use "successful POST to sources"

      test "custom field 1 should be correct in database" do
        source = Source.find_by_id(parsed_response_body["id"])
        assert_equal "custom 1",      source.custom["0"]["label"]
        assert_equal "description 1", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end

      test "custom field 2 should be correct in database" do
        source = Source.find_by_id(parsed_response_body["id"])
        assert_equal "custom 2",      source.custom["1"]["label"]
        assert_equal "description 2", source.custom["1"]["description"]
        assert_equal "integer",       source.custom["1"]["type"]
        assert_equal "805",           source.custom["1"]["value"]
      end
    end
  end

end

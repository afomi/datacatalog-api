require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DownloadsPostTest < RequestTestCase

  def app; DataCatalog::Downloads end

  before do
    @download_count = Download.count
  end
  
  %(curator).each do |role|
    context "#{role} API key : post / with correct params" do
      before do
        @source = create_source
        post "/", {
          :api_key   => primary_api_key_for(role),
          :url       => "http://example.gov/data/7",
          :format    => "xml",
          :source_id => @source.id,
        }
      end

      use "return 201 Created"
      use "return timestamps and id in body" 
      use "incremented download count"

      test "location header should point to new resource" do
        assert_include "Location", last_response.headers
        new_uri = "http://localhost:4567/downloads/" + parsed_response_body["id"]
        assert_equal new_uri, last_response.headers["Location"]
      end
      
      test "body should have correct fields" do
        r = parsed_response_body
        assert_equal "http://example.gov/data/7", r["url"]
        assert_equal "xml", r["format"]
        assert_equal @source.id.to_s, r["source_id"]
      end

      test "text should be correct in database" do
        download = Download.find_by_id!(parsed_response_body["id"])
        assert_equal "http://example.gov/data/7", download.url
        assert_equal "xml", download.format
        assert_equal @source.id.to_s, download.source_id
      end
    end
  end

end

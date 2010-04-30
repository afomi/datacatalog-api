require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ImportsPostTest < RequestTestCase

  def app; DataCatalog::Imports end

  before do
    @import_count = Import.count
  end

  context "curator API key : post / with correct params" do
    before do
      @importer = create_importer({
        :name => "data.gov"
      })
      timestamp = Time.now.utc
      @started_at = timestamp - 120
      @finished_at = timestamp
      post "/", {
        :api_key     => @curator_user.primary_api_key,
        :importer_id => @importer.id,
        :status      => 'succeeded',
        :started_at  => @started_at.to_s,
        :finished_at => @finished_at.to_s,
      }
    end
    
    after do
      @importer.destroy
    end
    
    use "return 201 Created"

    use "incremented import count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/imports/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct status" do
      assert_equal "succeeded", parsed_response_body["status"]
    end
    
    test "timestamps should be correct in database" do
      import = Import.find_by_id!(parsed_response_body["id"])
      assert_equal_times @started_at, import.started_at
      assert_equal_times @finished_at, import.finished_at
    end
  end

end

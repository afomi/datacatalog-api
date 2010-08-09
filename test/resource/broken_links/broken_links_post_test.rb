require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class BrokenLinksPostTest < RequestTestCase

  def app; DataCatalog::BrokenLinks end

  before do
    @broken_link_count = BrokenLink.count
  end

  context "curator API key : post / with correct params" do
    before do
      @source = create_source
      post "/", {
        :api_key         => @curator_user.primary_api_key,
        :source_id       => @source.id,
        :field           => "url",
        :destination_url => "http://broken.gov/stuff/88",
        :status          => 404,
      }
    end
    
    after do
      @source.destroy
    end

    use "return 201 Created"
    use "incremented broken_link count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/broken_links/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      parsed = parsed_response_body
      assert_equal "url",                        parsed["field"]
      assert_equal 404,                          parsed["status"]
      assert_equal "http://broken.gov/stuff/88", parsed["destination_url"]
    end
    
    test "text should be correct in database" do
      broken_link = BrokenLink.find_by_id!(parsed_response_body["id"])
      assert_equal "url", broken_link.field
    end
  end

end

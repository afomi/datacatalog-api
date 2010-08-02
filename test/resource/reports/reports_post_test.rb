require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ReportsPostTest < RequestTestCase

  def app; DataCatalog::Reports end

  before do
    @report_count = Report.count
  end

  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key   => @curator_user.primary_api_key,
        :text      => "Report A",
        :status    => 'new'
      }
    end

    use "return 201 Created"
    use "incremented report count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/reports/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct text" do
      assert_equal "Report A", parsed_response_body["text"]
    end

    test "text should be correct in database" do
      report = Report.find_by_id!(parsed_response_body["id"])
      assert_equal "Report A", report.text
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourceGroupsPostTest < RequestTestCase

  def app; DataCatalog::SourceGroups end

  before do
    @source_group_count = SourceGroup.count
  end

  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @curator_user.primary_api_key,
        :title   => "Source Group A",
      }
    end

    after do
      # ...
    end

    use "return 201 Created"
    use "incremented source group count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/source_groups/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct text" do
      assert_equal "Source Group A", parsed_response_body["title"]
    end

    test "text should be correct in database" do
      document = SourceGroup.find_by_id!(parsed_response_body["id"])
      assert_equal "Source Group A", document.title
    end
  end

end

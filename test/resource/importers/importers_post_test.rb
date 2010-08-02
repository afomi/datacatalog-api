require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ImportersPostTest < RequestTestCase

  def app; DataCatalog::Importers end

  before do
    @importer_count = Importer.count
  end

  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @curator_user.primary_api_key,
        :name    => "texas.gov",
      }
    end

    after do
    end

    use "return 201 Created"

    use "incremented importer count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/importers/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct status" do
      assert_equal "texas.gov", parsed_response_body["name"]
    end
  end

end

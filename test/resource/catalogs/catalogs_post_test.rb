require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CatalogsPostTest < RequestTestCase

  def app; DataCatalog::Catalogs end

  before do
    @catalog_count = Catalog.count
    @valid_params = {
      :title => "Catalog A",
      :url   => "http://www.test.gov/catalog",
    }
  end

  context "basic API key : post /" do
    before do
      post "/", {
        :api_key  => @normal_user.primary_api_key
      }.merge(@valid_params)
    end

    use "return 401 because the API key is unauthorized"
  end

  context "curator API key : post /" do
    before do
      post "/", {
        :api_key  => @curator_user.primary_api_key
      }.merge(@valid_params)
    end

    use "return 201 Created"
    use "incremented catalog count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/catalogs/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct values" do
      @valid_params.each do |key, value|
        assert_equal value, parsed_response_body[key.to_s]
      end
    end

    test "values should be correct in database" do
      catalog = Catalog.find_by_id!(parsed_response_body["id"])
      # TODO: use reload
      @valid_params.each do |key, value|
        assert_equal value, catalog[key]
      end
    end

    after do
      Catalog.find_by_title!("Catalog A").destroy
    end
  end

end

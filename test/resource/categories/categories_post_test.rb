require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategoriesPostTest < RequestTestCase

  def app; DataCatalog::Categories end

  before do
    @category_count = Category.count
  end

  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @curator_user.primary_api_key,
        :name    => "Category A",
      }
    end

    use "return 201 Created"
    use "incremented category count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/categories/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct text" do
      assert_equal "Category A", parsed_response_body["name"]
    end

    test "name should be correct in database" do
      category = Category.find_by_id!(parsed_response_body["id"])
      assert_equal "Category A", category.name
    end
  end

end

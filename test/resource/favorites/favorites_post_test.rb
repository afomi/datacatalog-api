require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class FavoritesPostTest < RequestTestCase

  def app; DataCatalog::Favorites end

  before do
    @source = create_source
    @favorite_count = Favorite.count
  end

  after do
    @source.destroy
  end

  context "incorrect API key : post /" do
    before do
      post "/",
        :api_key   => BAD_API_KEY,
        :source_id => @source.id
    end

    use "return 401 because the API key is invalid"
    use "unchanged favorite count"
  end

  context "basic API key : post / with correct params" do
    before do
      post "/",
        :api_key   => @normal_user.primary_api_key,
        :source_id => @source.id
    end

    use "return 201 Created"
    use "incremented favorite count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/favorites/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct values" do
      assert_equal @source.id.to_s, parsed_response_body['source_id']
      assert_equal @normal_user.id.to_s, parsed_response_body['user_id']
    end
  end

end

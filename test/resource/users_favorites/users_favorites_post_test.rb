require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersFavoritesPostTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user_with_primary_key
    @source = create_source(
      :title => "Example Source"
    )
  end

  after do
    @source.destroy
    @user.destroy
  end

  context "basic : post /:id/favorites" do
    before do
      post "/#{@user.id}/favorites",
        :source_id => @source.id,
        :api_key   => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
  end

  context "owner : post /:id/favorites" do
    before do
      post "/#{@user.id}/favorites",
        :source_id => @source.id,
        :api_key   => @user.primary_api_key
    end

    use "return 201 Created"

    test "updates database" do
      favorite = Favorite.find_by_id(parsed_response_body['id'])
      assert_equal @source.id, favorite.source_id
    end
  end

end

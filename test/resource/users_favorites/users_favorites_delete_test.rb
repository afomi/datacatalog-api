require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersFavoritesDeleteTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user_with_primary_key
    @source = create_source(
      :title => "Example Source"
    )
    @favorite = create_favorite(
      :user_id   => @user.id,
      :source_id => @source.id
    )
  end

  after do
    @favorite.destroy
    @source.destroy
    @user.destroy 
  end

  context "basic : delete /:id/favorites/:id" do
    before do
      delete "/#{@user.id}/favorites/#{@favorite.id}",
        :api_key   => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
  end

  context "owner : delete /:id/favorites/:id" do
    before do
      delete "/#{@user.id}/favorites/#{@favorite.id}",
        :api_key   => @user.primary_api_key
    end

    use "return 204 No Content"

    test "deleted in database" do
      assert_equal nil, Favorite.find_by_id(@favorite.id)
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class FavoritesPutTest < RequestTestCase

  def app; DataCatalog::Favorites end

  before do
    @user = create_user_with_primary_key
    @source = create_source
    @favorite = create_favorite(
      :source_id => @source.id,
      :user_id   => @user.id
    )
    @favorite_count = Favorite.count
  end

  after do
    @favorite.destroy
    @source.destroy
    @user.destroy
  end

  context "owner API key : put /:id with correct param" do
    before do
      @new_source = create_source
      put "/#{@favorite.id}", {
        :api_key   => @user.primary_api_key,
        :source_id => @new_source.id
      }
    end

    use "return 200 Ok"
    use "unchanged favorite count"

    test "source_id should be updated in database" do
      favorite = Favorite.find_by_id!(@favorite.id)
      assert_equal @new_source.id, favorite.source_id
    end
  end

end

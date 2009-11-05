require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class FavoritesDeleteTest < RequestTestCase

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
    @source.destroy
    @user.destroy
  end

  context "non owner API key : delete /:id" do
    before do
      delete "/#{@favorite.id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged favorite count"
  end
  
  context "curator API key : delete /:id" do
    before do
      delete "/#{@favorite.id}", :api_key => @curator_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged favorite count"
  end

  context "owner API key : delete /:id" do
    before do
      delete "/#{@favorite.id}", :api_key => @user.primary_api_key
    end
    
    use "return 204 No Content"
    use "decremented favorite count"
    
    test "favorite should be deleted in database" do
      assert_equal nil, Favorite.find_by_id(@favorite.id)
    end
  end

end

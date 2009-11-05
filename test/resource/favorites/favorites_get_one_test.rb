require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class FavoritesGetOneTest < RequestTestCase

  def app; DataCatalog::Favorites end

  before do
    @user = create_user_with_primary_key
    @source = create_source
    @favorite = create_favorite(
      :source_id => @source.id,
      :user_id   => @user.id
    )
  end
  
  after do
    @favorite.destroy
    @source.destroy
    @user.destroy
  end
  
  context "non owner API key" do
    before do
      get "/#{@favorite.id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
  end
  
  context "owner API key : get /:id" do
    before do
      get "/#{@favorite.id}", :api_key => @user.primary_api_key
    end

    use "return 200 Ok"
    
    doc_properties %w(source source_id user user_id
      id created_at updated_at)
    
    test "should have correct values" do
      assert_equal @source.id, parsed_response_body['source_id']
      assert_equal @user.id, parsed_response_body['user_id']
      assert_equal({
        'href'  => "/sources/#{@source.id}",
        'title' => @source.title,
      }, parsed_response_body['source'])
      assert_equal({
        'href' => "/users/#{@user.id}",
        'name' => @user.name,
      }, parsed_response_body['user'])
    end
  end

end

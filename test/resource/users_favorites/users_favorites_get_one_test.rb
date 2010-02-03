require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersFavoritesGetOneTest < RequestTestCase

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

  context "basic : get /:id/favorites/:id" do
    before do
      get "/#{@user.id}/favorites/#{@favorite.id}",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  context "owner : get /:id/favorites/:id" do
    before do
      get "/#{@user.id}/favorites/#{@favorite.id}",
        :api_key => @user.primary_api_key
    end
    
    use "return 200 Ok"
    doc_properties %w(source source_id id created_at updated_at)
    
    test "values should be correct" do
      expected = {
        "href"  => "/sources/#{@source.id}",
        "title" => "Example Source",
      }
      assert_equal expected, parsed_response_body['source']
      assert_equal @source.id.to_s, parsed_response_body['source_id']
    end
  end
  
end

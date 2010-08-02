require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersFavoritesPutTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user_with_primary_key
    @old_source = create_source(
      :title => "Old Source"
    )
    @updated_source = create_source(
      :title => "Updated Source"
    )
    @favorite = create_favorite(
      :user_id   => @user.id,
      :source_id => @old_source.id
    )
  end

  after do
    @favorite.destroy
    @old_source.destroy
    @updated_source.destroy
    @user.destroy
  end

  context "basic : put /:id/favorites/:id" do
    before do
      put "/#{@user.id}/favorites/#{@favorite.id}",
        :api_key   => @normal_user.primary_api_key,
        :source_id => @updated_source.id
    end

    use "return 401 because the API key is unauthorized"
  end

  context "owner : put /:id/favorites/:id" do
    before do
      put "/#{@user.id}/favorites/#{@favorite.id}",
        :api_key   => @user.primary_api_key,
        :source_id => @updated_source.id
    end

    use "return 200 Ok"
    doc_properties %w(source source_id id created_at updated_at)

    test "values should be correct" do
      expected = {
        "href"  => "/sources/#{@updated_source.id}",
        "title" => "Updated Source",
      }
      assert_equal expected, parsed_response_body['source']
    end
  end

end

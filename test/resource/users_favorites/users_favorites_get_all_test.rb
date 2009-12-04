require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersFavoritesGetAllTest < RequestTestCase

  def app; DataCatalog::Users end
  
  before :all do
    @user = create_user_with_primary_key
    @sources = 5.times.map do |i|
      create_source(
        :title => "Source #{i}"
      )
    end
    @favorites = 3.times.map do |i|
      create_favorite(
        :user_id   => @user.id,
        :source_id => @sources[i].id
      )
    end
  end

  after :all do
    @favorites.each { |x| x.destroy }
    @sources.each { |x| x.destroy }
    @user.destroy
  end

  context "basic : get /:id/favorites" do
    before do
      get "/#{@user.id}/favorites",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return an empty list of members"
    # This does not seem intuitive. However, it is consistent with:
    # 1. Users          having `permission :read => :basic`
    # 2. UsersFavorites having `permission :list => :basic`
  end

  context "owner : get /:id/favorites" do
    before do
      get "/#{@user.id}/favorites",
        :api_key => @user.primary_api_key
      @members = parsed_response_body['members']
    end
    
    use "return 200 Ok"
    members_properties %w(source source_id id created_at updated_at)
    
    test "values should be correct" do
      assert_equal 3, @members.length
      expected = ["Source 0", "Source 1", "Source 2"]
      actual = @members.map { |x| x['source']['title'] }.sort
      assert_equal expected, actual
    end
  end
  
end

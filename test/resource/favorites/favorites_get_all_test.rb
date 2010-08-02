require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class FavoritesGetAllTest < RequestTestCase

  def app; DataCatalog::Favorites end

  context "0 favorites" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 favorites" do
    before do
      @user = create_user_with_primary_key
      @sources = 3.times.map do |n|
        create_source(
          :title   => "Source #{n}",
          :user_id => @curator_user.id
        )
      end
      @favorites = 3.times.map do |n|
        create_favorite(
          :source_id => @sources[n].id,
          :user_id   => @user.id
        )
      end
    end

    after do
      @favorites.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
      @user.destroy
    end

    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 0 top level elements" do
        assert_equal 0, @members.length
      end
    end

    context "owner API key : get /" do
      before do
        get "/", :api_key => @user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end
    end
  end

end

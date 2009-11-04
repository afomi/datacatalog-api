require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class RatingsPutTest < RequestTestCase

  def app; DataCatalog::Ratings end

  before :all do
    @user = create_user_with_primary_key
    @source = create_source(
      :title => "Home Health Agency (HHA) Medicare Cost Report Data - FY 2004",
      :url   => "http://www.data.gov/details/769"
    )
    @rating = create_source_rating(
      :value     => 3,
      :text      => "Original Rating",
      :user_id   => @user.id,
      :source_id => @source.id
    )
    @rating_copy = @rating.dup
    @rating_count = Rating.count
  end

  context "basic API key : put /:id" do
    before do
      put "/#{@rating.id}", {
        :api_key => @normal_user.primary_api_key,
        :text    => "New Rating"
      }
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
    use "rating unchanged"
  end
  
  context "owner API key : put /:id" do
    before do
      put "/#{@rating.id}", {
        :api_key => @user.primary_api_key,
        :text    => "New Rating"
      }
    end
    
    use "return 200 Ok"
    use "unchanged rating count"
  
    test "text should be updated in database" do
      rating = Rating.find_by_id!(@rating.id)
      assert_equal "New Rating", rating.text
    end
  end

end

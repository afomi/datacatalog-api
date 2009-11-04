require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class RatingsDeleteTest < RequestTestCase

  def app; DataCatalog::Ratings end

  before do
    @source = create_source(
      :title => "2005-2007 American Community Survey Three-Year PUMS Population File",
      :url   => "http://www.data.gov/details/91"
    )
    @user = create_user_with_primary_key
    @rating = create_source_rating(
      :value     => 5,
      :text      => "Original Rating",
      :user_id   => @user.id,
      :source_id => @source.id
    )
    @rating_count = Rating.count
  end
  
  after do
    @rating.destroy
    @user.destroy
    @source.destroy
  end

  context "normal API key : delete /" do
    before do
      delete "/#{@rating.id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
  end
  
  context "curator API key : delete /:id" do
    before do
      delete "/#{@rating.id}", :api_key => @curator_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
  end

  context "owner API key : delete /" do
    before do
      delete "/#{@rating.id}", :api_key => @user.primary_api_key
    end
  
    use "return 204 No Content"
    use "decremented rating count"
  
    test "rating should be deleted in database" do
      assert_equal nil, Rating.find_by_id(@rating.id)
    end
  end

end

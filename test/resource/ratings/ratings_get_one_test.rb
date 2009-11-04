require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class RatingsGetOneTest < RequestTestCase

  def app; DataCatalog::Ratings end

  before do
    @user = create_user_with_primary_key
    @source = create_source(
      :title => "Consumer Expenditure Survey",
      :url   => "http://www.data.gov/details/319"
    )
    @rating = create_source_rating(
      :value     => 5,
      :text      => "Rating A",
      :user_id   => @user.id,
      :source_id => @source.id
    )
  end
  
  after do
    @rating.destroy
    @source.destroy
    @user.destroy
  end

  context "basic API key : get /:id" do
    before do
      get "/#{@rating.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  context "owner API key : get /:id" do
    before do
      get "/#{@rating.id}", :api_key => @user.primary_api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct text" do
      assert_equal "Rating A", parsed_response_body["text"]
    end

    doc_properties %w(
      kind
      user_id
      source_id
      comment_id
      value
      previous_value
      text
      id
      created_at
      updated_at
    )
  end

end

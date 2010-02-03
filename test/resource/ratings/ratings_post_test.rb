require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class RatingsPostTest < RequestTestCase

  def app; DataCatalog::Ratings end

  before do
    @source = create_source(
      :title => "Multifactor Productivity",
      :url   => "http://www.data.gov/details/332"
    )
    @comment = create_comment(:source_id => @source.id)
    @rating_count = Rating.count
  end

  shared "successful POST to ratings" do
    use "return 201 Created"
    use "incremented rating count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/ratings/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
  end
  
  context "basic API key : post / to create a source rating" do
    before do
      post "/", {
        :api_key   => @normal_user.primary_api_key,
        :kind      => "source",
        :source_id => @source.id,
        :text      => "Rating A",
        :value     => 5
      }
    end
    
    use "successful POST to ratings"
    
    test "body should have correct values" do
      r = parsed_response_body
      assert_equal @source.id.to_s, r['source_id']
      assert_equal "Rating A", r['text']
      assert_equal 5, r['value']
    end

    test "document in database should be correct" do
      rating = Rating.find_by_id!(parsed_response_body["id"])
      assert_equal @source.id.to_s, rating.source_id
      assert_equal "Rating A", rating.text
      assert_equal 5, rating.value
    end
  end
  
  context "basic API key : post / to create a comment rating" do
    before do
      post "/", {
        :api_key    => @normal_user.primary_api_key,
        :kind       => "comment",
        :comment_id => @comment.id,
        :value      => 1
      }
    end
    
    use "successful POST to ratings"
    
    test "body should have correct text" do
      r = parsed_response_body
      assert_equal @comment.id.to_s, r['comment_id']
      assert_equal 1, r['value']
    end
    
    test "text should be correct in database" do
      rating = Rating.find_by_id!(parsed_response_body["id"])
      assert_equal @comment.id.to_s, rating.comment_id
      assert_equal 1, rating.value
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsPostControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  before do
    @source = create_source
    @comment_count = Comment.count
  end
  
  after do
    @source.destroy
  end

  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key   => @curator_user.primary_api_key,
        :source_id => @source.id,
        :text      => "Comment A",
        :user_id   => @curator_user.id
      }
    end
    
    use "return 201 Created"
    use "incremented comment count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/comments/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      assert_equal "Comment A", parsed_response_body["text"]
    end
    
    test "text should be correct in database" do
      comment = Comment.find_by_id!(parsed_response_body["id"])
      assert_equal "Comment A", comment.text
    end
  end

end

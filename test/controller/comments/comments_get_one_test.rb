require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  before do
    @comment = Comment.create(
      :text      => "Comment A",
      :user_id   => get_fake_mongo_object_id,
      :source_id => get_fake_mongo_object_id
    )
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@comment.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct text" do
      assert_equal "Comment A", parsed_response_body["text"]
      assert_include "rating_stats", parsed_response_body
    end

    doc_properties %w(
      created_at
      id
      rating_stats
      source_id
      text
      updated_at
      user_id
    )
  end
  
end

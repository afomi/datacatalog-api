require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  before do
    @comment = create_comment(
      :text      => "Original Comment",
      :user_id   => get_fake_mongo_object_id,
      :source_id => get_fake_mongo_object_id
    )
    @comment_count = Comment.count
  end

  %w(curator).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@comment.id}", :api_key => primary_api_key_for(role)
      end
    
      use "return 204 No Content"
      use "decremented comment count"

      test "source should be deleted in database" do
        assert_equal nil, Comment.find_by_id(@comment.id)
      end
    end
  end

end

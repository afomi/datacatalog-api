require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsPutControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  before :all do
    @comment = Comment.create(
      :text      => "Original Comment",
      :user_id   => get_fake_mongo_object_id,
      :source_id => get_fake_mongo_object_id
    )
    @comment_count = Comment.count
  end

  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@comment.id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment"
      }
    end
    
    use "return 200 Ok"
    use "unchanged comment count"

    test "text should be updated in database" do
      comment = Comment.find_by_id(@comment.id)
      assert_equal "New Comment", comment.text
    end
  end

end

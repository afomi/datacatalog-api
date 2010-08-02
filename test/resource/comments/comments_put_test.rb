require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CommentsPutTest < RequestTestCase

  def app; DataCatalog::Comments end

  before do
    @user = create_user
    @source = create_source
    @comment = create_comment(
      :text      => "Original Comment",
      :user_id   => @user.id,
      :source_id => @source.id
    )
    @comment_count = Comment.count
  end

  after do
    @comment.destroy
    @source.destroy
    @user.destroy
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@comment.id}", {
        :api_key => @admin_user.primary_api_key,
        :user_id => @admin_user.id
      }
    end

    test "body should say 'created_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "user_id", parsed_response_body["errors"]["invalid_params"]
    end
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
      comment = Comment.find_by_id!(@comment.id)
      assert_equal "New Comment", comment.text
    end
  end

end

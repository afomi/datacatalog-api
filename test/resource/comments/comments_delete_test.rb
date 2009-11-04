require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CommentsDeleteTest < RequestTestCase

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
    @source.destroy
    @user.destroy
  end

  %w(admin).each do |role|
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

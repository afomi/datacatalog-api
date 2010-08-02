require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CommentsGetOneTest < RequestTestCase

  def app; DataCatalog::Comments end

  before do
    @user = create_user
    @source = create_source
    @comment = create_comment(
      :text      => "Comment A",
      :user_id   => @user.id,
      :source_id => @source.id
    )
  end

  after do
    @comment.destroy
    @source.destroy
    @user.destroy
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
      parent_id
      rating_stats
      reports_problem
      source_id
      text
      updated_at
      user_id
    )
  end

end

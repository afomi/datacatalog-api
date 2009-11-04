require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourcesUnitTest < RequestTestCase

  context "#nested_comment" do
    before do
      @user = create_user
      @source = create_source
      @parent_comment = create_comment(
        :user_id   => @user.id,
        :source_id => @source.id
      )
      @child_comment = create_comment(
        :user_id   => @user.id,
        :source_id => @source.id,
        :parent_id => @parent_comment.id
      )
    end
  
    after do
      @parent_comment.destroy
      @child_comment.destroy
      @source.destroy
      @user.destroy
    end
  
    test "parent comment should be correct" do
      actual = DataCatalog::Sources.nested_comment(@parent_comment)
      assert_properties %w(rating_stats href text user parent), actual
      assert_equal(nil, actual["parent"])
    end

    test "child comment should be correct" do
      actual = DataCatalog::Sources.nested_comment(@child_comment)
      assert_properties %w(rating_stats href text user parent), actual
      assert_equal({
        "href" => "/comments/#{@parent_comment.id}",
        "id"   => @parent_comment.id,
      }, actual["parent"])
    end
  end

end

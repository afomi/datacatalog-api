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
      assert_properties %w(rating_stats href text user parent created_at), actual
      assert_equal(nil, actual["parent"])
    end

    test "child comment should be correct" do
      actual = DataCatalog::Sources.nested_comment(@child_comment)
      assert_properties %w(rating_stats href text user parent created_at), actual
      assert_equal({
        "href" => "/comments/#{@parent_comment.id}",
        "id"   => @parent_comment.id,
      }, actual["parent"])
    end
  end

  context "#nested_organization" do
    before do
      @user = create_user
      @organization = create_organization(
        :name => "YMCA"
      )
      @source = create_source(
        :organization_id => @organization.id
      )
    end

    after do
      @source.destroy
      @organization.destroy
      @user.destroy
    end

    test "nested organization should be correct" do
      actual = DataCatalog::Sources.nested_organization(@source, @source.organization_id)
      assert_properties %w(href name slug), actual
      assert_equal "/organizations/#{@organization.id}", actual["href"]
      assert_equal "YMCA", actual["name"]
      assert_equal "ymca", actual["slug"]
    end
  end

end

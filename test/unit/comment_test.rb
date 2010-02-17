require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class CommentUnitTest < ModelTestCase

  shared "valid comment" do
    test "should be valid" do
      assert_equal true, @comment.valid?
    end
  end

  shared "invalid comment" do
    test "should not be valid" do
      assert_equal false, @comment.valid?
    end
  end

  shared "comment.text can't be empty" do
    test "should have error on text" do
      @comment.valid?
      assert_include :text, @comment.errors.errors
      assert_include "can't be empty", @comment.errors.errors[:text]
    end
  end

  shared "comment.user_id can't be empty" do
    test "should have error on user_id" do
      @comment.valid?
      assert_include :user_id, @comment.errors.errors
      assert_include "can't be empty", @comment.errors.errors[:user_id]
    end
  end

  shared "comment.source_id can't be empty" do
    test "should have error on source_id" do
      @comment.valid?
      assert_include :source_id, @comment.errors.errors
      assert_include "can't be empty", @comment.errors.errors[:source_id]
    end
  end

  shared "comment.comment_id can't be empty" do
    test "should have error on user_id" do
      @comment.valid?
      assert_include :comment_id, @comment.errors.errors
      assert_include "can't be empty", @comment.errors.errors[:comment_id]
    end
  end

  shared "comment.parent_id must be valid" do
    test "parent_id must be valid" do
      @comment.valid?
      assert_include :parent_id, @comment.errors.errors
      assert_include "must be valid", @comment.errors.errors[:parent_id]
    end
  end
  
  context "Comment" do
    before do
      @user = create_user
      @source = create_source
      @valid_params = {
        :text      => "An explanation",
        :user_id   => @user.id,
        :source_id => @source.id
      }
    end
    
    after do
      @source.destroy
      @user.destroy
    end
    
    context "missing text" do
      before do
        @comment = Comment.new(@valid_params.merge(:text => ""))
      end
      
      use "invalid comment"
      use "comment.text can't be empty"
    end

    context "missing user_id" do
      before do
        @comment = Comment.new(@valid_params.merge(:user_id => nil))
      end
      
      use "invalid comment"
      use "comment.user_id can't be empty"
    end
    
    context "missing source_id" do
      before do
        @comment = Comment.new(@valid_params.merge(:source_id => nil))
      end
      
      use "invalid comment"
      use "comment.source_id can't be empty"
    end
    
    context "invalid parent_id" do
      before do
        @comment = Comment.new(@valid_params.merge(
          :parent_id => get_fake_mongo_object_id
        ))
      end
    
      use "invalid comment"
      use "comment.parent_id must be valid"
    end
    
    context "correct params" do
      before do
        @comment = Comment.new(@valid_params)
      end
      
      use "valid comment"
    end
    
    context "with parent comment" do
      before do
        @user = create_user
        @source = create_source
        @parent_comment = create_comment(
          :user_id   => @user.id,
          :source_id => @source.id
        )
        @comment = Comment.new(@valid_params.merge(
          :parent_id => @parent_comment.id
        ))
      end
      
      after do
        @comment.destroy
        @parent_comment.destroy
        @source.destroy
        @user.destroy
      end
      
      test "association" do
        assert_equal @parent_comment.id, @comment.parent_id
        assert_equal @parent_comment, @comment.parent
      end
    end
  end

end

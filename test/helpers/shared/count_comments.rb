class RequestTestCase

  shared "incremented comment count" do
    test "should increment comment count" do
      assert_equal @comment_count + 1, Comment.count
    end
  end
  
  shared "unchanged comment count" do
    test "should not change comment count" do
      assert_equal @comment_count, Comment.count
    end
  end

  shared "decremented comment count" do
    test "should decrement comment count" do
      assert_equal @comment_count - 1, Comment.count
    end
  end
  
end

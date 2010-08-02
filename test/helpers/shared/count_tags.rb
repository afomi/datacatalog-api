class RequestTestCase

  shared "incremented tag count" do
    test "should increment tag count" do
      assert_equal @tag_count + 1, Tag.count
    end
  end

  shared "unchanged tag count" do
    test "should not change tag count" do
      assert_equal @tag_count, Tag.count
    end
  end

  shared "decremented tag count" do
    test "should decrement tag count" do
      assert_equal @tag_count - 1, Tag.count
    end
  end

end

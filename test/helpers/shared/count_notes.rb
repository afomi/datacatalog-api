class RequestTestCase

  shared "incremented note count" do
    test "should increment note count" do
      assert_equal @note_count + 1, Note.count
    end
  end

  shared "unchanged note count" do
    test "should not change note count" do
      assert_equal @note_count, Note.count
    end
  end

  shared "decremented note count" do
    test "should decrement note count" do
      assert_equal @note_count - 1, Note.count
    end
  end

end

class RequestTestCase

  shared "incremented broken_link count" do
    test "should increment broken_link count" do
      assert_equal @broken_link_count + 1, BrokenLink.count
    end
  end

  shared "unchanged broken_link count" do
    test "should not change broken_link count" do
      assert_equal @broken_link_count, BrokenLink.count
    end
  end

  shared "decremented broken_link count" do
    test "should decrement broken_link count" do
      assert_equal @broken_link_count - 1, BrokenLink.count
    end
  end

end

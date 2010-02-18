class RequestTestCase

  shared "incremented source group count" do
    test "should increment source group count" do
      assert_equal @source_group_count + 1, SourceGroup.count
    end
  end
  
  shared "unchanged source group count" do
    test "should not change source group count" do
      assert_equal @source_group_count, SourceGroup.count
    end
  end

  shared "decremented source group count" do
    test "should decrement source group count" do
      assert_equal @source_group_count - 1, SourceGroup.count
    end
  end
  
end

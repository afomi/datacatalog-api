class RequestTestCase

  shared "incremented download count" do
    test "should increment download count" do
      assert_equal @download_count + 1, Download.count
    end
  end
  
  shared "unchanged download count" do
    test "should not change download count" do
      assert_equal @download_count, Download.count
    end
  end

  shared "decremented download count" do
    test "should decrement download count" do
      assert_equal @download_count - 1, Download.count
    end
  end
  
end

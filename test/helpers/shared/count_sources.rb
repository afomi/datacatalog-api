class RequestTestCase

  shared "incremented source count" do
    test "should increment source count" do
      assert_equal @source_count + 1, Source.count
    end
  end

  shared "unchanged source count" do
    test "should not change source count" do
      assert_equal @source_count, Source.count
    end
  end

  shared "decremented source count" do
    test "should decrement source count" do
      assert_equal @source_count - 1, Source.count
    end
  end

end

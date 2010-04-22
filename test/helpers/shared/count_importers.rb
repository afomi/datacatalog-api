class RequestTestCase

  shared "incremented importer count" do
    test "should increment importer count" do
      assert_equal @importer_count + 1, Importer.count
    end
  end
  
  shared "unchanged importer count" do
    test "should not change importer count" do
      assert_equal @importer_count, Importer.count
    end
  end

  shared "decremented importer count" do
    test "should decrement importer count" do
      assert_equal @importer_count - 1, Importer.count
    end
  end
  
end

class RequestTestCase

  shared "incremented catalog count" do
    test "should increment catalog count" do
      assert_equal @catalog_count + 1, Catalog.count
    end
  end

  shared "unchanged catalog count" do
    test "should not change catalog count" do
      assert_equal @catalog_count, Catalog.count
    end
  end

  shared "decremented catalog count" do
    test "should decrement catalog count" do
      assert_equal @catalog_count - 1, Catalog.count
    end
  end

end

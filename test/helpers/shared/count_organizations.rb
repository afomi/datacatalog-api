class RequestTestCase

  shared "incremented organization count" do
    test "should increment organization count" do
      assert_equal @organization_count + 1, Organization.count
    end
  end

  shared "unchanged organization count" do
    test "should not change organization count" do
      assert_equal @organization_count, Organization.count
    end
  end

  shared "decremented organization count" do
    test "should decrement organization count" do
      assert_equal @organization_count - 1, Organization.count
    end
  end

end

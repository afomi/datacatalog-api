class RequestTestCase

  shared "incremented report count" do
    test "should increment report count" do
      assert_equal @report_count + 1, Report.count
    end
  end
  
  shared "unchanged report count" do
    test "should not change report count" do
      assert_equal @report_count, Report.count
    end
  end

  shared "decremented report count" do
    test "should decrement report count" do
      assert_equal @report_count - 1, Report.count
    end
  end
  
end

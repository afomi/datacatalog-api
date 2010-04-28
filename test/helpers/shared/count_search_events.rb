class RequestTestCase

  shared "incremented search_event count" do
    test "should increment search_event count" do
      assert_equal @search_event_count + 1, SearchEvent.count
    end
  end
  
  shared "unchanged search_event count" do
    test "should not change search_event count" do
      assert_equal @search_event_count, SearchEvent.count
    end
  end

  shared "decremented search_event count" do
    test "should decrement search_event count" do
      assert_equal @search_event_count - 1, SearchEvent.count
    end
  end
  
end

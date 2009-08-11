class RequestTestCase

  shared "incremented document count" do
    test "should increment document count" do
      assert_equal @document_count + 1, Document.count
    end
  end
  
  shared "unchanged document count" do
    test "should not change document count" do
      assert_equal @document_count, Document.count
    end
  end

  shared "decremented document count" do
    test "should decrement document count" do
      assert_equal @document_count - 1, Document.count
    end
  end
  
end

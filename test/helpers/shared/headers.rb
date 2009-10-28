class RequestTestCase

  shared "content type header indicates JSON" do
    test "should have JSON content type" do
      assert_equal "application/json", last_response.headers["Content-Type"]
    end
  end

  shared "content type header not set" do
    test "should not have Content-Type set" do
      assert_equal nil, last_response.headers["Content-Type"]
    end
  end

end

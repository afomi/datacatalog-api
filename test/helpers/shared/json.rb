class RequestTestCase

  shared "return JSON" do
    test "should have JSON content type" do
      assert_equal "application/json", last_response.headers["Content-Type"]
    end
  end

end

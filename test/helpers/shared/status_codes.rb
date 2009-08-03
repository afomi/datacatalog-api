class RequestTestCase
  
  shared "return 200 Ok" do
    test "status should be 200 Ok" do
      assert_equal 200, last_response.status
    end
  end

  shared "return 201 Created" do
    test "status should be 201 Created" do
      assert_equal 201, last_response.status
    end
    
    test "location header should start with http://localhost" do
      assert_include "Location", last_response.headers
      generic_uri = %r{^http://localhost}
      assert_match generic_uri, last_response.headers["Location"]
    end
  end

  shared "return 400 Bad Request" do
    test "status should be 400 Bad Request" do
      assert_equal 400, last_response.status
    end
  end

  shared "return 401 Unauthorized" do
    test "status should be 401 Unauthorized" do
      assert_equal 401, last_response.status
    end
  end

  shared "return 404 Not Found" do
    test "status should be 404 Not Found" do
      assert_equal 404, last_response.status
    end
  end

end
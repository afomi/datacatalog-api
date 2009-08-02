class RequestTestCase

  shared "return an empty response body" do
    test "should return []" do
      assert_equal [], parsed_response_body
    end
  end

  shared "return timestamps and id in body" do
    use "return timestamps in body"
    use "return id in body"
  end
  
  shared "return timestamps in body" do
    test "body should have created_at" do
      assert_include "created_at", parsed_response_body
    end

    test "body should have updated_at" do
      assert_include "updated_at", parsed_response_body
    end
  end
  
  shared "return id in body" do
    test "body should have id" do
      assert_include "id", parsed_response_body
    end

    test "body should not have _id" do
      assert_not_include "_id", parsed_response_body
    end
  end

end

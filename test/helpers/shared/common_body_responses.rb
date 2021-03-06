class RequestTestCase

  shared "return an empty response body" do
    test "should return empty response body" do
      # TODO: the following line is only temporary
      assert_equal true, last_response.body == "" || last_response.body == "null"

      # TODO: the following line is probably what I want:
      # assert_equal "", last_response.body

      # TODO: this line is the old way
      # assert_equal "null", last_response.body
    end
  end

  shared "return an empty list response body" do
    test "should return []" do
      assert_equal [], parsed_response_body
    end
  end

  shared "return an empty list of members" do
    test "members should return []" do
      assert_equal [], parsed_response_body['members']
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
    test "body should have correctly formatted id" do
      assert_include "id", parsed_response_body
      assert_equal 0, (/^[0-9a-fA-F]{24}$/ =~ parsed_response_body["id"])
    end

    test "body should not have _id" do
      assert_not_include "_id", parsed_response_body
    end
  end

end

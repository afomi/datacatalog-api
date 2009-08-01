module TimestampsAndId
  
  def self.included(mod)
    mod.test "body should have created_at" do
      assert_include "created_at", parsed_response_body
    end

    mod.test "body should have updated_at" do
      assert_include "updated_at", parsed_response_body
    end

    mod.test "body should have id" do
      assert_include "id", parsed_response_body
    end

    mod.test "body should not have _id" do
      assert_not_include "_id", parsed_response_body
    end
  end

end

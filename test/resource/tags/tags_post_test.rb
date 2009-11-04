require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TagsPostTest < RequestTestCase

  def app; DataCatalog::Tags end

  before do
    @tag_count = Tag.count
  end

  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @curator_user.primary_api_key,
        :text    => "Tag A",
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented tag count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/tags/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      assert_equal "Tag A", parsed_response_body["text"]
    end
    
    test "text should be correct in database" do
      tag = Tag.find_by_id!(parsed_response_body["id"])
      assert_equal "Tag A", tag.text
    end
  end

end

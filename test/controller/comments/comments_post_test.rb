require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsPostControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  before do
    @comment_count = Comment.count
  end

  # - - - - - - - - - -

  shared "successful POST to comments" do
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented comment count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/comments/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      assert_equal "Comment A", parsed_response_body["text"]
    end
    
    test "text should be correct in database" do
      comment = Comment.find_by_id(parsed_response_body["id"])
      assert_equal "Comment A", comment.text
    end
  end
  
  # - - - - - - - - - -

  context "anonymous : post /" do
    before do
      post "/", {
        :text      => "Comment A",
        :source_id => get_fake_mongo_object_id
      }
    end
    
    use "return 401 because the API key is missing"
    use "unchanged comment count"
  end
  
  context "incorrect API key : post /" do
    before do
      post "/", {
        :api_key   => "does_not_exist_in_database",
        :source_id => get_fake_mongo_object_id,
        :text      => "Comment A",
      }
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged comment count"
  end
  
  context "normal API key : post /" do
    before do
      post "/", {
        :api_key   => @normal_user.primary_api_key,
        :source_id => get_fake_mongo_object_id,
        :text      => "Comment A",
      }
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged comment count"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : post / with protected param" do
    before do
      post "/", {
        :api_key    => @admin_user.primary_api_key,
        :source_id  => get_fake_mongo_object_id,
        :text       => "Comment A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "return errors hash saying updated_at is invalid"
  end

  context "admin API key : post / with invalid param" do
    before do
      post "/", {
        :api_key   => @admin_user.primary_api_key,
        :source_id => get_fake_mongo_object_id,
        :text      => "Comment A",
        :junk      => "This is an extra param (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "return errors hash saying junk is invalid"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key   => @curator_user.primary_api_key,
        :source_id => get_fake_mongo_object_id,
        :text      => "Comment A"
      }
    end
    
    use "successful POST to comments"
  end

  context "admin API key : post / with correct params" do
    before do
      post "/", {
        :api_key   => @admin_user.primary_api_key,
        :source_id => get_fake_mongo_object_id,
        :text      => "Comment A"
      }
    end
  
    use "successful POST to comments"
  end

end

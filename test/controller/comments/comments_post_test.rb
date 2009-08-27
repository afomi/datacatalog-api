require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsPostControllerTest < RequestTestCase

  before do
    @comment_count = Comment.count
  end

  # - - - - - - - - - -

  context "anonymous user : post /comments" do
    before do
      post '/comments'
    end
    
    use "return 401 because the API key is missing"
    use "unchanged comment count"
  end
  
  context "incorrect user : post /comments" do
    before do
      post '/comments', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged comment count"
  end
  
  context "normal user : post /comments" do
    before do
      post '/comments', :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged comment count"
  end
  
  # - - - - - - - - - -

  context "admin user : post /comments : protected param 'updated_at'" do
    before do
      post '/comments', {
        :api_key    => @admin_user.primary_api_key,
        :text       => "Comment A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "return errors hash saying updated_at is invalid"
  end
  
  context "admin user : post /comments : extra param 'junk'" do
    before do
      post '/comments', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Comment A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "return errors hash saying junk is invalid"
  end
  
  # - - - - - - - - - -
  
  context "admin user : post /comments : correct params" do
    before do
      post '/comments', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Comment A",
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented comment count"
      
    test "location header should point to new recomment" do
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

end

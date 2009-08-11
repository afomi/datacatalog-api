require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsPutControllerTest < RequestTestCase

  before do
    @comment = Comment.create({
      :text => "Original Comment"
    })
    @id = @comment.id
    @fake_id = get_fake_mongo_object_id
    @comment_count = Comment.count
  end

  # - - - - - - - - - -
  
  shared "unchanged text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Comment", @comment.text
    end
  end

  # - - - - - - - - - -

  context "anonymous user : put /comments" do
    before do
      put "/comments/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged comment count"
  end

  context "incorrect user : put /comments" do
    before do
      put "/comments/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged comment count"
  end

  context "unconfirmed user : put /comments" do
    before do
      put "/comments/#{@id}", :api_key => @unconfirmed_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged comment count"
  end
  
  context "confirmed user : put /comments" do
    before do
      put "/comments/#{@id}", :api_key => @confirmed_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged comment count"
  end

  # - - - - - - - - - -

  context "admin user : put /comments : attempt to create : protected param" do
    before do
      put "/comments/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Comment",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged comment count"
    use "unchanged text in database"
  end

  context "admin user : put /comments : attempt to create : extra param" do
    before do
      put "/comments/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment",
        :extra   => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged comment count"
    use "unchanged text in database"
  end
  
  context "admin user : put /comments : attempt to create : correct params" do
    before do
      put "/comments/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged comment count"
    use "unchanged text in database"
  end
  
  # - - - - - - - - - -
  
  context "admin user : put /comments : update : protected param" do
    before do
      put "/comments/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Comment",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "unchanged text in database"
  
    test "body should say 'updated_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "updated_at", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin user : put /comments : update : extra param" do
    before do
      put "/comments/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment",
        :extra   => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "unchanged text in database"
  
    test "body should say 'extra' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "extra", parsed_response_body["errors"]["invalid_params"]
    end
  end

  # - - - - - - - - - -
  
  context "admin user : put /comments : update : correct params" do
    before do
      put "/comments/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment"
      }
    end
  
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged comment count"
  
    test "text should be updated in database" do
      comment = Comment.find_by_id(@id)
      assert_equal "New Comment", comment.text
    end
  end

end

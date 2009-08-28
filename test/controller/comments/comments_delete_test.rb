require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsDeleteControllerTest < RequestTestCase

  before do
    comment = Comment.create :text => "Original Comment"
    @id = comment.id
    @comment_count = Comment.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : delete /comments" do
    before do
      delete "/comments/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged comment count"
  end

  context "incorrect API key : delete /comments" do
    before do
      delete "/comments/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged comment count"
  end

  context "normal API key : delete /comments" do
    before do
      delete "/comments/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged comment count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /comments/:fake_id" do
    before do
      delete "/comments/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged comment count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /comments/:id" do
    before do
      delete "/comments/#{@id}", :api_key => @admin_user.primary_api_key
    end

    use "return 200 Ok"
    use "decremented comment count"

    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end

    test "comment should be deleted in database" do
      assert_equal nil, Comment.find_by_id(@id)
    end
  end

  context "admin API key : double delete /users" do
    before do
      delete "/comments/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/comments/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented comment count"
  
    test "should be deleted in database" do
      assert_equal nil, Comment.find_by_id(@id)
    end
  end

end

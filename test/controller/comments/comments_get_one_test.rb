require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsGetOneControllerTest < RequestTestCase

  before do
    comment = Comment.create :text => "Comment A"
    @id = comment.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : get /comments/:id" do
    before do
      get "/comments/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /comments/:id" do
    before do
      get "/comments/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal API key : get /comments/:id" do
    before do
      get "/comments/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : get /comments/:fake_id : not found" do
    before do
      get "/comments/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin API key : get /comments/:id : found" do
    before do
      get "/comments/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Comment A", parsed_response_body["text"]
    end
  end

end

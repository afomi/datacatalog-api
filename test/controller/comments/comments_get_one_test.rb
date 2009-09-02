require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  before do
    comment = Comment.create :text => "Comment A"
    @id = comment.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "attempted GET comment with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
  end

  shared "successful GET comment with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Comment A", parsed_response_body["text"]
    end
    
    test "body should have user_id" do
      assert_include "user_id", parsed_response_body
    end
  end

  # - - - - - - - - - -

  context "anonymous : get /:id" do
    before do
      get "/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /:id" do
    before do
      get "/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  # - - - - - - - - - -
  
  context "normal API key : get /:fake_id" do
    before do
      get "/#{@fake_id}", :api_key => @normal_user.primary_api_key
    end
    
    use "attempted GET comment with :fake_id"
  end
  
  context "admin API key : get /:fake_id" do
    before do
      get "/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "attempted GET comment with :fake_id"
  end
  
  # - - - - - - - - - -
  
  context "normal API key : get /:id" do
    before do
      get "/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "successful GET comment with :id"
  end
  
  context "admin API key : get /:id" do
    before do
      get "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "successful GET comment with :id"
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class DocumentsGetOneControllerTest < RequestTestCase

  before do
    document = Document.create :text => "Document A"
    @id = document.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous user : get /documents/:id" do
    before do
      get "/documents/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /documents/:id" do
    before do
      get "/documents/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "unconfirmed user : get /documents/:id" do
    before do
      get "/documents/#{@id}", :api_key => @unconfirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  context "confirmed user : get /documents/:id" do
    before do
      get "/documents/#{@id}", :api_key => @confirmed_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  # - - - - - - - - - -
  
  context "admin user : get /documents/:fake_id : not found" do
    before do
      get "/documents/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin user : get /documents/:id : found" do
    before do
      get "/documents/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Document A", parsed_response_body["text"]
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class DocumentsPostControllerTest < RequestTestCase

  before do
    @document_count = Document.count
  end

  # - - - - - - - - - -

  context "anonymous user : post /documents" do
    before do
      post '/documents'
    end
    
    use "return 401 because the API key is missing"
    use "unchanged document count"
  end
  
  context "incorrect user : post /documents" do
    before do
      post '/documents', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged document count"
  end
  
  context "normal user : post /documents" do
    before do
      post '/documents', :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged document count"
  end
  
  # - - - - - - - - - -

  context "admin user : post /documents : protected param 'updated_at'" do
    before do
      post '/documents', {
        :api_key    => @admin_user.primary_api_key,
        :text       => "Document A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged document count"
  
    test "body should say 'updated_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "updated_at", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin user : post /documents : extra param 'junk'" do
    before do
      post '/documents', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Document A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged document count"
  
    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  # - - - - - - - - - -
  
  context "admin user : post /documents : correct params" do
    before do
      post '/documents', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Document A",
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented document count"
      
    test "location header should point to new redocument" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/documents/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      assert_equal "Document A", parsed_response_body["text"]
    end
    
    test "text should be correct in database" do
      document = Document.find_by_id(parsed_response_body["id"])
      assert_equal "Document A", document.text
    end
  end

end
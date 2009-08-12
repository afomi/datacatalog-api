require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class DocumentsGetAllControllerTest < RequestTestCase
  
  context "anonymous user : get /documents" do
    before do
      get '/documents'
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /documents" do
    before do
      get '/documents', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end

  context "normal user : get /documents" do
    before do
      get '/documents', :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  # - - - - - - - - - -

  context "admin user : get /documents : 0" do
    before do
      get '/documents', :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return an empty response body"
  end
  
  context "admin user : get /documents : 3" do
    before do
      3.times do |n|
        Document.create :text => "Document #{n}"
      end
      get '/documents', :api_key => @admin_user.primary_api_key
    end
    
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "body should have correct text" do
      actual = (0 ... 3).map { |n| parsed_response_body[n]["text"] }
      3.times { |n| assert_include "Document #{n}", actual }
    end
  
    3.times do |n|
      test "element #{n} should have created_at" do
        assert_include "created_at", parsed_response_body[n]
      end
        
      test "element #{n} should have updated_at" do
        assert_include "updated_at", parsed_response_body[n]
      end
      
      test "element #{n} should have id" do
        assert_include "id", parsed_response_body[n]
      end
        
      test "element #{n} should not have _id" do
        assert_not_include "_id", parsed_response_body[n]
      end
    end
  end

end

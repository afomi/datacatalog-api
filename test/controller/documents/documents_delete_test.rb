require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class DocumentsDeleteControllerTest < RequestTestCase

  before do
    document = Document.create :text => "Original Document"
    @id = document.id
    @document_count = Document.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : delete /documents" do
    before do
      delete "/documents/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged document count"
  end

  context "incorrect API key : delete /documents" do
    before do
      delete "/documents/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged document count"
  end

  context "normal API key : delete /documents" do
    before do
      delete "/documents/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged document count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /documents/:fake_id" do
    before do
      delete "/documents/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged document count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /documents/:id" do
    before do
      delete "/documents/#{@id}", :api_key => @admin_user.primary_api_key
    end

    use "return 200 Ok"
    use "decremented document count"

    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end

    test "document should be deleted in database" do
      assert_equal nil, Document.find_by_id(@id)
    end
  end

  context "admin API key : double delete /users" do
    before do
      delete "/documents/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/documents/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented document count"
  
    test "document should be deleted in database" do
      assert_equal nil, Document.find_by_id(@id)
    end
  end

end

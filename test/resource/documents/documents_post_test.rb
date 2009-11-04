require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DocumentsPostControllerTest < RequestTestCase

  def app; DataCatalog::Documents end

  before do
    @document_count = Document.count
  end

  context "curator API key : post / with correct params" do
    before do
      @source = create_source
      post "/", {
        :api_key   => @curator_user.primary_api_key,
        :text      => "Document A",
        :source_id => @source.id
      }
    end
    
    after do
      @source.destroy
    end
    
    use "return 201 Created"
    use "incremented document count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/documents/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      assert_equal "Document A", parsed_response_body["text"]
    end
    
    test "text should be correct in database" do
      document = Document.find_by_id!(parsed_response_body["id"])
      assert_equal "Document A", document.text
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class DocumentsPutControllerTest < RequestTestCase

  def app; DataCatalog::Documents end

  before :all do
    @source = create_source
    @document = create_document(
      :text      => "Original Document",
      :source_id => @source.id
    )
    @document_count = Document.count
  end
  
  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@document.id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Document"
      }
    end
    
    use "return 200 Ok"
    use "unchanged document count"

    test "text should be updated in database" do
      document = Document.find_by_id(@document.id)
      assert_equal "New Document", document.text
    end
  end

end

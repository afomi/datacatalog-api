require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DocumentsPutTest < RequestTestCase

  def app; DataCatalog::Documents end

  before :all do
    @source = create_source
    @document = create_document(
      :text      => "Original Document",
      :source_id => @source.id
    )
    @document_count = Document.count
  end
  
  after :all do
    @document.destroy
    @source.destroy
  end
  
  context "basic API key : put /:id with correct param" do
    before :all do
      put "/#{@document.id}", {
        :api_key => @normal_user.primary_api_key,
        :text    => "New Document"
      }
      # Since an update (PUT) automatically creates a new version, this
      # code has to be in a before :all block.
    end
    
    use "return 200 Ok"
    
    # Updating a document creates a new version.
    # (Yes, this differs from the usual pattern for *_put_test.rb files.)
    use "incremented document count"

    test "document in database should be correct" do
      document = Document.find_by_id!(@document.id)
      # TODO: use reload in the future
      assert_equal "New Document", document.text
      assert_equal @source.id, document.source_id
    end
    
    doc_properties %w(
      text
      source_id
      user_id
      next_id
      previous_id
      id
      updated_at
      created_at
    )
    
    test "previous version should be correct" do
      document = Document.find_by_id!(@document.id)
      # TODO: use reload in the future
      previous_document = Document.find_by_id!(document.previous_id)
      assert_equal "Original Document", previous_document.text
      assert_equal @source.id, previous_document.source_id
    end
    
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DocumentsDeleteTest < RequestTestCase

  def app; DataCatalog::Documents end

  before do
    @source = create_source
    @document = create_document(
      :source_id => @source.id
    )
    @document_count = Document.count
  end

  %w(curator).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@document.id}", :api_key => primary_api_key_for(role)
      end

      use "return 204 No Content"
      use "decremented document count"

      test "source should be deleted in database" do
        assert_equal nil, Document.find_by_id(@document.id)
      end
    end
  end


end

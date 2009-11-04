require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DocumentsGetAllTest < RequestTestCase

  def app; DataCatalog::Documents end

  context "0 documents" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "return 200 Ok"
      use "return an empty list response body"
    end
  end

  context "3 documents" do
    before do
      @documents = 3.times.map do |n|
        source = create_source
        create_document(
          :text      => "Document #{n}",
          :source_id => source.id
        )
      end
    end

    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      test "body should have 3 top level elements" do
        assert_equal 3, parsed_response_body.length
      end
    
      test "body should have correct text" do
        actual = (0 ... 3).map { |n| parsed_response_body[n]["text"] }
        3.times { |n| assert_include "Document #{n}", actual }
      end
    end
  end

end

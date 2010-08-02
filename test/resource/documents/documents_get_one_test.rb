require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DocumentsGetOneTest < RequestTestCase

  def app; DataCatalog::Documents end

  before do
    @source = create_source
    @document = create_document(
      :source_id => @source.id
    )
  end

  after do
    @source.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@document.id}", :api_key => @normal_user.primary_api_key
    end

    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "Sample Document", parsed_response_body["text"]
    end

    test "body should have user_id" do
      assert_include "user_id", parsed_response_body
    end

    test "body should have previous_id" do
      assert_include "previous_id", parsed_response_body
    end
  end

end

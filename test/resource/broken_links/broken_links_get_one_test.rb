require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class BrokenLinksGetOneTest < RequestTestCase

  def app; DataCatalog::BrokenLinks end

  before do
    @source = create_source
    @broken_link = create_broken_link(
      :source_id => @source.id
    )
  end

  after do
    @broken_link.destroy
    @source.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@broken_link.id}", :api_key => @curator_user.primary_api_key
    end
    
    use "return 200 Ok"

    test "body should have correct text" do
      parsed = parsed_response_body
      assert_equal "documentation_url", parsed["field"]
      assert_equal "http://broken-link.gov/1002", parsed["destination_url"]
      assert_equal 404, parsed["status"]
    end

    doc_properties %w(
      created_at
      destination_url
      field
      id
      organization_id
      source_id
      status
      updated_at
    )
  end

end

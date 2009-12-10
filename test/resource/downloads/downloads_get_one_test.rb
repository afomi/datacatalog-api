require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DownloadsGetOneTest < RequestTestCase

  def app; DataCatalog::Downloads end

  before do
    @source = create_source
    @download = create_download(
      :url       => "http://example.gov/data/7",
      :format    => "xml",
      :source_id => @source.id
    )
  end
  
  after do
    @download.destroy
    @source.destroy
  end
  
  %w(normal).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@download.id}", :api_key => primary_api_key_for(role)
      end
  
      use "return 200 Ok"

      test "body should have correct values" do
        r = parsed_response_body
        assert_equal "http://example.gov/data/7", r["url"]
        assert_equal "xml", r["format"]
      end

      doc_properties %w(
        url
        format
        preview
        source_id
        created_at
        updated_at
        id
      )
    end
  end

end

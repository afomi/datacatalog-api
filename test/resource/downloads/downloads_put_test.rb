require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class DownloadsPutTest < RequestTestCase

  def app; DataCatalog::Downloads end

  before do
    @source = create_source
    @download = create_download(
      :url       => "http://example.gov/data/7",
      :format    => "xml",
      :source_id => @source.id
    )
    @download_count = Download.count
  end

  after do
    @download.destroy
    @source.destroy
  end

  %w(curator).each do |role|
    context "#{role} API key : put /:id with correct param" do
      before do
        @new_source = create_source
        put "/#{@download.id}", {
          :api_key   => primary_api_key_for(role),
          :source_id => @new_source.id
        }
      end

      use "return 200 Ok"
      use "unchanged download count"

      test "source_id should be updated in database" do
        download = Download.find_by_id!(@download.id)
        assert_equal @new_source.id, download.source_id
      end
    end
  end

end

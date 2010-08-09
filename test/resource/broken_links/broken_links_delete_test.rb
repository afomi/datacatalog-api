require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class BrokenLinksDeleteTest < RequestTestCase

  def app; DataCatalog::BrokenLinks end

  before do
    @source = create_source
    @broken_link = create_broken_link({
      :field     => "original",
      :source_id => @source.id
    })
    @broken_link_count = BrokenLink.count
  end

  after do
    @source.destroy
  end

  %w(admin).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@broken_link.id}", :api_key => primary_api_key_for(role)
      end

      use "return 204 No Content"
      use "decremented broken_link count"

      test "broken_link should be deleted in database" do
        assert_equal nil, BrokenLink.find_by_id(@broken_link.id)
      end
    end
  end

end

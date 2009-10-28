require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    @source = Source.create(
      :title => "The Original Data Source",
      :url   => "http://data.gov/original"
    )
    @source_count = Source.count
  end
  
  after do
    @source.destroy
  end

  shared "successful DELETE source with :id" do
    use "return 204 No Content"
    use "decremented source count"

    test "source should be deleted in database" do
      assert_equal nil, Source.find_by_id(@source.id)
    end
  end
  
  %w(curator admin).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@source.id}", :api_key => primary_api_key_for(role)
      end
    
      use "successful DELETE source with :id"
    end
  end
  
end

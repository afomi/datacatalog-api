require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourceGroupsDeleteTest < RequestTestCase

  def app; DataCatalog::SourceGroups end

  before do
    @source_group = create_source_group
    @source_group_count = SourceGroup.count
  end

  %w(curator).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@source_group.id}", :api_key => primary_api_key_for(role)
      end
    
      use "return 204 No Content"
      use "decremented source_group count"

      test "source group should be deleted in database" do
        assert_equal nil, SourceGroup.find_by_id(@source_group.id)
      end
    end
  end


end

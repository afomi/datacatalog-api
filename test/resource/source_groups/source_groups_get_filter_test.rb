require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourceGroupsGetFilterTest < RequestTestCase

  def app; DataCatalog::SourceGroups end

  context "6 documents" do
    before do
      @source_groups = 3.times.map do |n|
        create_source_group({
          :title => "Source Group #{n}",
        })
      end
    end
    
    after do
      @source_groups.each { |x| x.destroy }
    end
    
    context "normal API key : get / where text is 'Document 2'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => "title:'Source Group 2'"
        @members = parsed_response_body['members']
      end
    
      test "body should have 1 top level elements" do
        assert_equal 1, @members.length
      end

      test "each element should be correct" do
        @members.each do |element|
          assert_equal 'Source Group 2', element["title"]
          assert_equal 'source-group-2', element["slug"]
        end
      end
    end
  end
end

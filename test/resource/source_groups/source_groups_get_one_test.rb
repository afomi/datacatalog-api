require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourceGroupsGetOneTest < RequestTestCase

  def app; DataCatalog::SourceGroups end

  before do
    @source_group = create_source_group({
      :title => "Sample Source Group"
    })
  end
  
  context "normal API key : get /:id" do
    before do
      get "/#{@source_group.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct text" do
      assert_equal "Sample Source Group", parsed_response_body["title"]
    end
  end

end

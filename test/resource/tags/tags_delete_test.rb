require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TagsDeleteTest < RequestTestCase

  def app; DataCatalog::Tags end

  before do
    @tag = create_tag(:text => "Original Tag")
    @tag_count = Tag.count
  end
  
  %w(admin).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@tag.id}", :api_key => primary_api_key_for(role)
      end
    
      use "return 204 No Content"
      use "decremented tag count"

      test "tag should be deleted in database" do
        assert_equal nil, Tag.find_by_id(@tag.id)
      end
    end
  end

end

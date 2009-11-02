require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class TagsPutControllerTest < RequestTestCase

  def app; DataCatalog::Tags end

  before do
    @tag = create_tag(:text => "Original Tag")
    @tag_count = Tag.count
  end
  
  after do
    @tag.destroy
  end

  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@tag.id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag"
      }
    end
    
    use "return 200 Ok"
    use "unchanged tag count"

    test "text should be updated in database" do
      tag = Tag.find_by_id!(@tag.id)
      assert_equal "New Tag", tag.text
    end
  end

end

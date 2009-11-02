require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CategoriesPutControllerTest < RequestTestCase

  def app; DataCatalog::Categories end

  before :all do
    @category = create_category(
      :name => "Original Category"
    )
    @category_count = Category.count
  end


  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@category.id}", {
        :api_key => @curator_user.primary_api_key,
        :name    => "New Category"
      }
    end
    
    use "return 200 Ok"
    use "unchanged category count"

    test "text should be updated in database" do
      category = Category.find_by_id!(@category.id)
      assert_equal "New Category", category.name
    end
  end

end

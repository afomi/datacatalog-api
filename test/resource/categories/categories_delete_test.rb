require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategoriesDeleteTest < RequestTestCase

  def app; DataCatalog::Categories end

  before do
    @category = create_category(:name => "Original Category")
    @category_count = Category.count
  end
  
  # - - - - - - - - - -

  shared "successful DELETE category with :id" do
    use "return 204 No Content"
    use "decremented category count"

    test "category should be deleted in database" do
      assert_equal nil, Category.find_by_id(@id)
    end
  end

  %w(curator).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@category.id}", :api_key => primary_api_key_for(role)
      end
    
      use "successful DELETE category with :id"
    end
  end

end

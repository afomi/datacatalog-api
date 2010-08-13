require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategoriesDeleteTest < RequestTestCase

  def app; DataCatalog::Categories end

  before do
    @user = create_user
    @source = create_source
    @category = create_category(:name => "Category-1")
    @categorization = create_categorization(:source_id => @source.id, :category_id => @category.id)
    @categorization_count = Categorization.count
  end

  after do
    @categorization.destroy
    @category.destroy
    @source.destroy
    @user.destroy
  end

  # - - - - - - - - - -

  shared "successful DELETE categorization with :id" do
    use "return 204 No Content"
    use "decremented categorization count"

    test "categorization should be deleted in database" do
      assert_equal nil, Categorization.find_by_id(@categorization.id)
    end
  end

  %w(curator).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@categorization.id}", :api_key => primary_api_key_for(role)
      end

      use "successful DELETE categorization with :id"
    end
  end

end

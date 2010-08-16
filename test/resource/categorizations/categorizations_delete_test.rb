require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategorizationsDeleteTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  before do
    @source = create_source
    @category = create_category(:name => "Category-1")
    @categorization = create_categorization(:source_id => @source.id, :category_id => @category.id)
    @categorization_count = Categorization.count
  end

  after do
    @categorization.destroy
    @category.destroy
    @source.destroy
  end

  # - - - - - - - - - -

  %w(curator).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@categorization.id}", :api_key => primary_api_key_for(role)
      end
      
      use "return 204 No Content"
      use "decremented categorization count"

      test "categorization should be deleted in database" do
        assert_equal nil, Categorization.find_by_id(@categorization.id)
      end
    end
  end

end


require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategoriesGetOneTest < RequestTestCase

  def app; DataCatalog::Categories end

  before do
    @category = create_category(
      :name => "Category A"
    )
  end
  
  after do
    @category.destroy
  end

  shared "successful GET category with :id" do
    use "return 200 Ok"
  
    test "body should have correct text" do
      assert_equal "Category A", parsed_response_body["name"]
    end

    doc_properties %w(
      created_at
      id
      name
      source_ids
      updated_at
    )
  end

  %w(normal).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@category.id}", :api_key => primary_api_key_for(role)
      end
      
      use "successful GET category with :id"
    end
    
    context "#{role} API key : 2 categorizations : get /:id" do
      before do
        @sources = [
          create_source({
            :title => "Macroeconomic Indicators 2008",
            :url   => "http://www.macro.gov/indicators/2008"
          }),
          create_source({
            :title => "Macroeconomic Indicators 2009",
            :url   => "http://www.macro.gov/indicators/2009"
          }),
        ]
        @sources.each do |source|
          c = create_categorization(
            :category_id => @category.id,
            :source_id   => source.id
          )
        end
        get "/#{@category.id}", :api_key => primary_api_key_for(role)
      end
    
      use "successful GET category with :id"
      
      test "body should have correct source_ids" do
        actual = parsed_response_body["source_ids"]
        expected = @sources.map { |source| source.id.to_s }
        assert_equal expected, actual
      end
    end
  end

end

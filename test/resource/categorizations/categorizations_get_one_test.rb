require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategorizationsGetOneTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  before do
    @source = create_source
    @category = create_category(:name => "Category 1")
    @categorization = create_categorization(:source_id => @source.id, :category_id => @category.id)
  end

  after do
    @categorization.destroy
    @source.destroy
    @category.destroy
  end

  shared "successful GET categorization with :id" do
    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "Category 1", parsed_response_body["category"]["name"]
    end

#    doc_properties %w(
#      source_id
#      category_id
#    )
  end

  %w(normal).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@categorization.id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET categorization with :id"
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
        get "/#{@categorization.id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET categorization with :id"

#      test "body should have correct source_ids" do
#        actual = parsed_response_body["source_id"]
#        expected = @sources.map { |source| source.id.to_s }
#        assert_equal expected, actual
#      end
    end
  end

end

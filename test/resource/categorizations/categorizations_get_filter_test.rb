require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategorizationsGetFilterTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  # Probably shouldn't be able to create multiple Categorizations
  # for the same Source/Category combo
  context "6 categorizations" do
    before do
      @source = create_source
      @category = create_category(:name => "Category 1")
      @categorizations = 6.times.map do |n|
        create_categorization(:source_id => @source.id, :category_id => @category.id)
      end
    end

    after do
      @categorizations.each { |x| x.destroy }
      @category.destroy
      @source.destroy
    end

    context "normal API key : get / where category_id is the category's id" do
      before do
        get "/", {
          :api_key => @normal_user.primary_api_key,
          :filter  => %(category_id="#{@category.id}")
        }
        @members = parsed_response_body['members']
      end

      test "body should have 6 top level elements" do
        assert_equal 6, @members.length
      end

      test "each element should be correct" do
        @members.each do |element|
          assert_equal @category.id.to_s, element["category_id"]
          assert_equal @source.id.to_s, element["source_id"]
        end
      end
    end
  end

end

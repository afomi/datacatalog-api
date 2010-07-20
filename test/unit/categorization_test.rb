require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class CategorizationUnitTest < ModelTestCase

  context "Source" do
    before do
      [Categorization, Category, Source].each { |m| m.destroy_all }
      @source = create_source
    end
    
    after do
      @source.destroy
    end
  
    context "with no Categorizations" do
      test "#categorizations should be empty" do
        assert @source.categorizations.empty?
      end
    end

    context "with 3 Categorizations" do
      before do
        @categories = %w(Energy Finance Poverty).map do |name|
          create_category(:name => name)
        end
        @categorizations = @categories.map do |category|
          create_categorization(
            :source_id   => @source.id,
            :category_id => category.id
          )
        end
      end
    
      test "Source#categorizations should be correct" do
        categorizations = @source.categorizations
        categorizations.each do |categorization|
          assert_include categorization, @categorizations
        end
      end
    
      test "Source#categories should be correct" do
        categories = @source.categories
        @categories.each do |category|
          assert_include category, categories
        end
      end

      test "Category#sources should be correct" do
        @categories.each do |category|
          assert_include @source, category.sources
        end
      end
    end
  end
  
end

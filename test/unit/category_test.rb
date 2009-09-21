require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class CategoryUnitTest < ModelTestCase

  shared "valid category" do
    test "should be valid" do
      assert_equal true, @category.valid?
    end
  end

  shared "invalid category" do
    test "should not be valid" do
      assert_equal false, @category.valid?
    end
  end

  shared "category.name can't be empty" do
    test "should have error on text" do
      @category.valid?
      assert_include :name, @category.errors.errors
      assert_include "can't be empty", @category.errors.errors[:name]
    end
  end

  # - - - - - - - - - -
  
  context "Category.new" do
    before do
      @valid_params = {
        :name => "Science & Technology"
      }
    end
    
    context "correct params" do
      before do
        @category = Category.new(@valid_params)
      end
      
      use "valid category"
    end

    context "missing name" do
      before do
        @category = Category.new(@valid_params.merge(:name => ""))
      end
      
      use "invalid category"
      use "category.name can't be empty"
    end
  end

end

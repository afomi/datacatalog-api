require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class ImporterUnitTest < ModelTestCase
  
  shared "valid Importer" do
    test "should be valid" do
      assert_equal true, @importer.valid?
    end
  end

  shared "invalid Importer" do
    test "should not be valid" do
      assert_equal false, @importer.valid?
    end
  end

  shared "importer.name can't be empty" do
    test "should have empty error on name" do
      @importer.valid?
      assert_include :name, @importer.errors.errors
      assert_include "can't be empty", @importer.errors.errors[:name]
    end
  end

  # - - - - - - - - - -
  
  context "Importer : source" do
    before do
      @valid_params = {
        :name        => "data.gov",
      }
    end
    
    after do
    end
    
    context "correct params" do
      before do
        @importer = Importer.new(@valid_params)
      end
      
      use "valid Importer"
    end

    context "missing name" do
      before do
        @importer = Importer.new(@valid_params.merge(:name => nil))
      end
      
      use "invalid Importer"
      use "Importer.name can't be empty"
    end
  end
  
end

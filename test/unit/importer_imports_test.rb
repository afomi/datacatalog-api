require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class ImporterImportsUnitTest < ModelTestCase
  
  context "Importer.create" do
    before do
      @importer = create_importer({
        :name => "texas.gov"
      })
      @imports = [
        create_import({
          :importer_id => @importer.id,
        }),
        create_import({
          :importer_id => @importer.id,
        })
      ]
    end
    
    after do
      @imports.each do |import|
        import.destroy
      end
    end

    test "imports should be valid" do
      @imports.each do |import|
        assert import.valid?
      end
    end
    
    test "importer.imports should be correct" do
      imports = @importer.imports.all
      assert_equal 2, imports.length
      imports.each do |import|
        assert_include import, @imports
      end
    end

  end
  
end

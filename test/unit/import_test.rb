require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class ImportUnitTest < ModelTestCase
  
  shared "valid Import" do
    test "should be valid" do
      assert_equal true, @import.valid?
    end
  end

  shared "invalid Import" do
    test "should not be valid" do
      assert_equal false, @import.valid?
    end
  end

  shared "import.importer_id can't be empty" do
    test "should have empty error on importer_id" do
      @import.valid?
      assert_include :importer_id, @import.errors.errors
      assert_include "can't be empty", @import.errors.errors[:importer_id]
    end
  end

  shared "import.start_time can't be empty" do
    test "should have empty error on start_time" do
      @import.valid?
      assert_include :start_time, @import.errors.errors
      assert_include "can't be empty", @import.errors.errors[:start_time]
    end
  end

  shared "import.finish_time can't be empty" do
    test "should have empty error on finish_time" do
      @import.valid?
      assert_include :finish_time, @import.errors.errors
      assert_include "can't be empty", @import.errors.errors[:finish_time]
    end
  end

  shared "import.status must be valid" do
    test "should have error on status" do
      @import.valid?
      assert_include :status, @import.errors.errors
      assert_include "must be one of: success, failure",
        @import.errors.errors[:status]
    end
  end

  # - - - - - - - - - -
  
  context "Import : source" do
    before do
      finish = Time.now
      @importer = create_importer({
        :name => "Austin, TX"
      })
      @valid_params = {
        :importer_id => @importer.id,
        :start_time  => finish - 30,
        :finish_time => finish,
        :status      => 'success',
      }
    end
    
    after do
      @importer.destroy
    end
    
    context "correct params" do
      before do
        @import = Import.new(@valid_params)
      end
      
      use "valid Import"
      
      test "calculate correct duration" do
        @import.valid? # triggers before|after_validation callbacks
        assert_equal 30, @import.duration
      end
      
      test "point to associated importer" do
        assert_equal @importer, @import.importer
      end
    end

    context "missing importer_id" do
      before do
        @import = Import.new(@valid_params.merge(:importer_id => nil))
      end
      
      use "invalid Import"
      use "import.importer_id can't be empty"
    end

    context "missing start_time" do
      before do
        @import = Import.new(@valid_params.merge(:start_time => nil))
      end
      
      use "invalid Import"
      use "import.start_time can't be empty"
    end

    context "missing finish_time" do
      before do
        @import = Import.new(@valid_params.merge(:finish_time => nil))
      end
      
      use "invalid Import"
      use "import.finish_time can't be empty"
    end
    
    context "invalid status" do
      before do
        @import = Import.new(@valid_params.merge(:status => ""))
      end
      
      use "invalid Import"
      use "import.status must be valid"
    end
    
  end
  
end

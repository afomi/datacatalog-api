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

  shared "import.started_at can't be empty" do
    test "should have empty error on started_at" do
      @import.valid?
      assert_include :started_at, @import.errors.errors
      assert_include "can't be empty", @import.errors.errors[:started_at]
    end
  end

  shared "import.finished_at can't be empty" do
    test "should have empty error on finished_at" do
      @import.valid?
      assert_include :finished_at, @import.errors.errors
      assert_include "can't be empty", @import.errors.errors[:finished_at]
    end
  end

  shared "import.status must be valid" do
    test "should have error on status" do
      @import.valid?
      assert_include :status, @import.errors.errors
      assert_include "must be one of: started, succeeded, failed",
        @import.errors.errors[:status]
    end
  end

  # - - - - - - - - - -
  
  context "Import : succeeded" do
    before do
      finish = Time.now
      @importer = create_importer({
        :name => "Austin, TX"
      })
      @valid_params = {
        :importer_id => @importer.id,
        :started_at  => finish - 30,
        :finished_at => finish,
        :status      => 'succeeded',
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

    context "missing started_at" do
      before do
        @import = Import.new(@valid_params.merge(:started_at => nil))
      end
      
      use "invalid Import"
      use "import.started_at can't be empty"
    end

    context "missing finished_at" do
      before do
        @import = Import.new(@valid_params.merge(:finished_at => nil))
      end
      
      use "invalid Import"
      use "import.finished_at can't be empty"
    end
    
    context "invalid status" do
      before do
        @import = Import.new(@valid_params.merge(:status => ""))
      end
      
      use "invalid Import"
      use "import.status must be valid"
    end
  end

  context "Import : started" do
    before do
      started = Time.now
      @importer = create_importer({
        :name => "Roosevelt, TX"
      })
      @valid_params = {
        :importer_id => @importer.id,
        :started_at  => started,
        :status      => 'started',
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
    end
  end

end

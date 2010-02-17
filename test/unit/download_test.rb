require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class DownloadUnitTest < ModelTestCase
  
  shared "valid download" do
    test "should be valid" do
      assert_equal true, @download.valid?
    end
  end

  shared "invalid download" do
    test "should not be valid" do
      assert_equal false, @download.valid?
    end
  end

  shared "download.format can't be empty" do
    test "text should not be empty" do
      @download.valid?
      assert_include :format, @download.errors.errors
      assert_include "must be empty", @download.errors.errors[:format]
    end
  end

  shared "download.source_id can't be empty" do
    test "should have empty error on source_id" do
      @download.valid?
      assert_include :source_id, @download.errors.errors
      assert_include "can't be empty", @download.errors.errors[:source_id]
    end
  end

  shared "download.source_id must be valid" do
    test "should have invalid error on source_id" do
      @download.valid?
      assert_include :source_id, @download.errors.errors
      assert_include "must be valid", @download.errors.errors[:source_id]
    end
  end

  shared "download.source must be a dataset" do
    test "should have invalid error on source" do
      @download.valid?
      assert_include :source, @download.errors.errors
      assert_include "must have dataset source_type", @download.errors.errors[:source]
    end
  end

  # - - - - - - - - - -
  
  context "Download : source" do
    before do
      @source = create_source
      @valid_params = {
        :format    => "xml",
        :url       => "http://big-data.net/datasets/343",
        :source_id => @source.id,
      }
    end
    
    after do
      @source.destroy
    end
    
    context "correct params" do
      before do
        @download = Download.new(@valid_params)
      end
      
      use "valid download"
    end

    context "invalid source_id" do
      before do
        @download = Download.new(@valid_params.merge(
          :source_id => get_fake_mongo_object_id
        ))
      end
      
      use "invalid download"
      use "download.source_id must be valid"
    end

    context "missing source_id" do
      before do
        @download = Download.new(@valid_params.merge(:source_id => nil))
      end
      
      use "invalid download"
      use "download.source_id can't be empty"
    end
    
    context "correct size" do
      before do
        @download = Download.new(
          @valid_params.merge({
            :size => {
              'number' => 120,
              'unit'   => 'KB',
              'bytes'  => 120 * 1024,
            }
          })
        )
      end
      
      use "valid download"
    end

    context "incorrect unit" do
      before do
        @download = Download.new(
          @valid_params.merge({
            :size => {
              'number' => 120,
              'unit'   => 'x',
              'bytes'  => 120 * 1024,
            }
          })
        )
      end
      
      use "invalid download"

      test "should have error on size" do
        @download.valid?
        assert_include :size, @download.errors.errors
        assert_include "unit must be one of: B KB MB TB PB EB",
          @download.errors.errors[:size]
      end
    end

    context "incorrect number" do
      before do
        @download = Download.new(
          @valid_params.merge({
            :size => {
              'number' => 'one hundred',
              'unit'   => 'KB',
              'bytes'  => 100 * 1024,
            }
          })
        )
      end
      
      use "invalid download"

      test "should have error on size" do
        @download.valid?
        assert_include :size, @download.errors.errors
        assert_include "number must be an integer or float if present",
          @download.errors.errors[:size]
      end
    end

    context "incorrect bytes" do
      before do
        @download = Download.new(
          @valid_params.merge({
            :size => {
              'number' => 100,
              'unit'   => 'KB',
              'bytes'  => "a bunch",
            }
          })
        )
      end
      
      use "invalid download"

      test "should have error on size" do
        @download.valid?
        assert_include :size, @download.errors.errors
        assert_include "bytes must be an integer or float if present",
          @download.errors.errors[:size]
      end
    end
    
  end
  
end

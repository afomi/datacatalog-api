require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceUnitTest < ModelTestCase

  shared "valid source" do
    test "should be valid" do
      assert_equal true, @source.valid?
    end
  end

  shared "invalid source" do
    test "should not be valid" do
      assert_equal false, @source.valid?
    end
  end

  shared "source.url can't be empty" do
    test "should have error on url - can't be empty" do
      @source.valid?
      assert_include :url, @source.errors.errors
      assert_include "can't be empty", @source.errors.errors[:url]
    end
  end

  shared "source.url must be absolute" do
    test "should have error on url - must be absolute" do
      @source.valid?
      assert_include :url, @source.errors.errors
      assert_include "URI must be absolute", @source.errors.errors[:url]
    end
  end

  shared "source.url must be http or ftp" do
    test "should have error on url - must be http or ftp" do
      @source.valid?
      assert_include :url, @source.errors.errors
      assert_include "URI scheme must be http or ftp", @source.errors.errors[:url]
    end
  end

  # - - - - - - - - - -

  context "Source.new" do
    before do
      @valid_params = {
        :url => "http://data.gov/sources/1492"
      }
    end

    context "correct params" do
      before do
        @source = Source.new(@valid_params)
      end

      use "valid source"
    end

    context "url with port" do
      before do
        @source = Source.new(@valid_params.merge(
          :url => "http://other-data.com:8080/42"
        ))
      end

      use "valid source"
    end

    context "ftp url" do
      before do
        @source = Source.new(@valid_params.merge(
          :url => "ftp://data.gov/42"
        ))
      end

      use "valid source"
    end
    
    # - - - - - - - - - -

    context "missing url" do
      before do
        @source = Source.new(@valid_params.merge(:url => ""))
      end

      use "invalid source"
      use "source.url can't be empty"
    end

    context "relative url" do
      before do
        @source = Source.new @valid_params.merge(:url => "/source/1999")
      end

      use "invalid source"
      use "source.url must be absolute"
    end

    context "https url" do
      before do
        @source = Source.new @valid_params.merge(
          :url => "https://sekret.com/1999"
        )
      end

      use "invalid source"
      use "source.url must be http or ftp"
    end
  end
  
  # - - - - - - - - - -
  
  context "updating a Source" do
    before do
      Source.destroy_all
      doc = Source.create(:url => "http://original.gov")
      @original_id = doc._id
      @original_created_at = doc.created_at
      @original_updated_at = doc.updated_at

      sleep_enough_for_mongo_timestamps_to_differ
      doc.url = "http://updated.gov"
      doc.save
      @updated = doc
    end

    test "should have updated url" do
      assert_equal "http://updated.gov", @updated.url
    end

    test "should have an unchanged created_at" do
      assert_equal_mongo_times @original_created_at, @updated.created_at
    end

    test "body should have an updated updated_at" do
      assert_different_mongo_times @original_updated_at, @updated.updated_at
    end
    
    test "body should have an unchanged _id" do
      assert_equal @original_id, @updated._id
    end
  end
  
end

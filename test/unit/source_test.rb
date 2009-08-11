require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceUnitTest < ModelTestCase
  
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

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SourceUnitTest < Test::Unit::TestCase
  
  context "updating a Source" do
    
    before :all do
      reset_sources_data
      doc = Source.create(:url => "http://original.gov")
      @original = doc.dup
      
      doc.url = "http://updated.gov"
      doc.save
      @updated = doc
    end

    test "should have updated url" do
      assert_equal "http://updated.gov", @updated.url
    end

    test "should have an unchanged created_at" do
      assert_equal @original.created_at, @updated.created_at
    end

    test "body should have an updated updated_at" do
      assert_not_equal @original.updated_at, @updated.updated_at
    end
    
    test "body should have an unchanged _id" do
      assert_equal @original._id, @updated._id
    end

  end
  
end

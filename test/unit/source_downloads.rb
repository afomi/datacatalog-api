require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceDownloadsUnitTest < ModelTestCase
  
  context "source with no downloads" do
    before do
      @source = create_source
    end
    
    test "#downloads should return []" do
      assert_equal [], @source.downloads
    end
  end
  
  context "source with 3 downloads" do
    before do
      @user = create_normal_user
      @source = create_source
      @downloads = []
      3.times do |n|
        @downloads << create_download(
          :url       => "http://opendata.gov/data/#{n}",
          :format    => "xml",
          :source_id => @source.id
        )
      end
    end
    
    after do
      @downloads.each { |x| x.destroy }
      @source.destroy
      @user.destroy
    end
    
    test "#downloads should return 3 objects" do
      assert_equal 3, @source.downloads.length
    end
    
    3.times do |n|
      test "#downloads should include value of #{n}" do
        assert_include "http://opendata.gov/data/#{n}", @source.downloads.map(&:url)
      end
      
      test "finding id for #{n} should succeed" do
        assert_equal @downloads[n], @source.downloads.find(@downloads[n].id)
      end
    end
    
    test "find with fake_id should not raise exception" do
      assert_equal nil, @source.downloads.find(get_fake_mongo_object_id)
    end

    test "find! with fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @source.downloads.find!(get_fake_mongo_object_id)
      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceRatingsUnitTest < ModelTestCase
  
  context "source with no ratings" do

    before do
      @source = Source.create(:url => "http://data.gov/data-sets/123")
    end
    
    test "#ratings should return []" do
      assert_equal [], @source.ratings
    end

  end

  context "source with 5 ratings" do

    before do
      @source = Source.create(:url => "http://data.gov/data-sets/123")
      @ratings = []
      5.times do |n|
        @ratings << Rating.create(:value => n)
      end
      @source.ratings = @ratings
      @source.save!
    end
    
    test "#ratings should return 5 objects" do
      assert_equal 5, @source.ratings.length
    end
    
    5.times do |n|
      test "#ratings should include value of #{n}" do
        assert_include n, @source.ratings.map(&:value)
      end
      
      test "finding id for #{n} should succeed" do
        assert_equal @ratings[n], @source.ratings.find(@ratings[n].id)
      end
    end
    
    # This behavior probably will be changing soon in MongoMapper
    #
    # * find will return nil and find! will raise exception
    # * wherever find is called it should behave the same whether
    #   associations or plain old documents
    test "finding fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @source.ratings.find get_fake_mongo_object_id
      end
    end

  end
  
end

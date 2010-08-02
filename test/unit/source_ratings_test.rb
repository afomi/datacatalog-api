require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceRatingsUnitTest < ModelTestCase

  context "source with no ratings" do
    before do
      @source = create_source(
        :title => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url   => "http://www.data.gov/details/90"
      )
    end

    after do
      @source.destroy
    end

    test "#ratings should return []" do
      assert_equal [], @source.ratings
    end
  end

  context "source with 5 ratings" do
    before :all do
      @user = create_user
      @source = create_source(
        :title => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url   => "http://www.data.gov/details/90"
      )
      @ratings = 5.times.map do |n|
        Rating.create!(
          :kind      => "source",
          :value     => n + 1,
          :text      => "Source Rating #{n + 1}",
          :user_id   => @user.id,
          :source_id => @source.id
        )
      end
      @source.ratings = @ratings
      @source.save!
    end

    after :all do
      @source.destroy
      @ratings.each { |x| x.destroy }
      @user.destroy
    end

    test "#ratings should return 5 objects" do
      assert_equal 5, @source.ratings.length
    end

    5.times do |n|
      test "#ratings should include value of #{n}" do
        assert_include n + 1, @source.ratings.map(&:value)
      end

      test "finding id for #{n} should succeed" do
        assert_equal @ratings[n], @source.ratings.first(:_id => @ratings[n].id)
      end
    end

    test "find with fake_id should not raise exception" do
      assert_equal nil, @source.ratings.first(:_id => get_fake_mongo_object_id)
    end

    test "find! with fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @source.ratings.find!(get_fake_mongo_object_id)
      end
    end
  end

end

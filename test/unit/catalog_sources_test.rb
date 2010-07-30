require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class CatalogSourcesUnitTest < ModelTestCase

  context "catalog with no sources" do
    before do
      @catalog = create_catalog
    end

    after do
      @catalog.destroy
    end

    test "#sources should return []" do
      assert_equal [], @catalog.sources
    end
  end

  context "catalog with 3 sources" do
    before :all do
      @user = create_normal_user
      @catalog = create_catalog
      @sources = []
      3.times do |n|
        @sources << create_source(
          :title      => "Source #{n}",
          :catalog_id => @catalog.id,
          :user_id    => @user.id
        )
      end
    end

    after :all do
      @sources.each { |x| x.destroy }
      @catalog.destroy
      @user.destroy
    end

    test "#sources should return 3 objects" do
      assert_equal 3, @catalog.sources.length
    end

    3.times do |n|
      test "#sources should include value of #{n}" do
        assert_include "Source #{n}", @catalog.sources.map(&:title)
      end

      test "finding id for #{n} should succeed" do
        assert_equal @sources[n], @catalog.sources.find(@sources[n].id)
      end
    end

    test "find with fake_id should not raise exception" do
      assert_equal nil, @catalog.sources.find(get_fake_mongo_object_id)
    end

    test "find! with fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @catalog.sources.find!(get_fake_mongo_object_id)
      end
    end
  end

end

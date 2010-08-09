require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class CatalogScoringUnitTest < ModelTestCase

  context "catalog with no sources" do
    before do
      @catalog = create_catalog
    end

    after do
      @catalog.destroy
    end

    test "#score_stats should return default hash" do
      expected = {
        'total'   => nil,
        'count'   => 0,
        'average' => nil
      }
      assert_equal expected, @catalog.score_stats
    end
    
    test "#add_score should work" do
      @catalog.add_score(10)
      stats = @catalog.score_stats
      assert_equal 10, stats['total']
      assert_equal 1, stats['count']
      assert_equal 10, stats['average']
    end

    test "#add_score (2X) should work" do
      @catalog.add_score(10)
      @catalog.add_score(20)
      stats = @catalog.score_stats
      assert_equal 30, stats['total']
      assert_equal 2, stats['count']
      assert_equal 15, stats['average']
    end

    test "#remove_score should raise exception" do
      assert_raise DataCatalog::Error do
        @catalog.remove_score(10)
      end
    end

    test "#add_score_to then #remove_score should work" do
      @catalog.add_score(10)
      @catalog.remove_score(10)
      stats = @catalog.score_stats
      assert_equal nil, stats['total']
      assert_equal 0, stats['count']
      assert_equal nil, stats['average']
    end

    test "#add_score (2X) then #remove_score should work" do
      @catalog.add_score(10)
      @catalog.add_score(20)
      @catalog.remove_score(10)
      stats = @catalog.score_stats
      assert_equal 20, stats['total']
      assert_equal 1, stats['count']
      assert_equal 20, stats['average']
    end

    test "#add_score then #update_score should work" do
      @catalog.add_score(10)
      @catalog.update_score(20, 10)
      stats = @catalog.score_stats
      assert_equal 20, stats['total']
      assert_equal 1, stats['count']
      assert_equal 20, stats['average']
    end
  end

  context "catalog with 1 source" do
    before :all do
      @catalog = create_catalog
      @source = create_source({
        :title       => "2009 Wallet Card",
        :slug        => "2009-wallet-card",
        :url         => "http://www.data.gov/tools/468",
        :source_type => "interactive",
        :frequency   => "annually",
        :catalog_id  => @catalog.id
      })
      @catalog.reload
    end

    after :all do
      @source.destroy
      @catalog.destroy
    end

    test "#score_stats should return correct count" do
      assert_equal 1, @catalog.score_stats['count']
    end

    test "#score_stats should return correct average" do
      assert_equal 4, @catalog.score_stats['average']
    end

    test "#score_stats should contain proper keys" do
      assert_properties %w(total count average), @catalog.score_stats
    end
  end

end

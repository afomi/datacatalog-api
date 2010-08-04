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
  end

end

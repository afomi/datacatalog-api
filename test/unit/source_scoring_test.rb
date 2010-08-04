require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceScoringUnitTest < ModelTestCase

  context "scoring" do
    before do
      @base_params = {
        :title       => "2009 Wallet Card",
        :slug        => "2009-wallet-card",
        :url         => "http://www.data.gov/tools/468",
        :source_type => "interactive",
        :frequency   => "annually",
      }
      @source = Source.new(@base_params)
    end

    test "nil if unsaved" do
      assert_equal nil, @source.score
    end

    context "saved" do
      before do
        @source.save!
      end

      after do
        @source.destroy
      end

      test "set after save" do
        assert_equal 4, @source.score
      end

      test "no change if unsaved after adding field" do
        @source.license = "public domain"
        assert_equal 4, @source.score
      end

      test "decrease after removing field" do
        @source.frequency = nil
        @source.save!
        assert_equal 3, @source.score
      end

      test "increase after removing field" do
        @source.license = "public domain"
        @source.save!
        assert_equal 5, @source.score
      end
    end

  end

end

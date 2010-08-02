require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')
require 'timecop'

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

  shared "source.source_type must be correct" do
    test "should be invalid when not 'api', 'dataset', or 'interactive'" do
      @source.valid?
      assert_include :source_type, @source.errors.errors
      assert_equal ["must be one of: api, dataset, interactive"],
        @source.errors.errors[:source_type]
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

  shared "source.url must be http, https, or ftp" do
    test "should have error on url - must be http, https, or ftp" do
      @source.valid?
      assert_include :url, @source.errors.errors
      assert_include "URI scheme must be http, https, or ftp", @source.errors.errors[:url]
    end
  end

  shared "source.frequency is invalid" do
    test "should have error on frequency" do
      @source.valid?
      assert_include :frequency, @source.errors.errors
      assert_include "is invalid", @source.errors.errors[:frequency]
    end
  end

  shared "source.period_start is invalid" do
    test "should have error period_start" do
      @source.valid?
      assert_include :period_start, @source.errors.errors
      assert_include "is invalid", @source.errors.errors[:period_start]
    end
  end

  shared "source.period_end is invalid" do
    test "should have error on period_end" do
      @source.valid?
      assert_include :period_end, @source.errors.errors
      assert_include "is invalid", @source.errors.errors[:period_end]
    end
  end

  context "Source" do
    before do
      @valid_params = {
        :title       => "Migratory Bird Flyways - Continental United States",
        :url         => "http://www.data.gov/details/12",
        :source_type => "dataset",
      }
    end

    context "correct params" do
      before do
        @source = Source.new(@valid_params)
      end

      use "valid source"
    end

    context "source_type" do
      context "missing" do
        before do
          @source = Source.new(@valid_params.merge(:source_type => ""))
        end

        use "invalid source"
        use "source.source_type must be correct"
      end

      context "invalid" do
        before do
          @source = Source.new(@valid_params.merge(:source_type => "foobar"))
        end

        use "invalid source"
        use "source.source_type must be correct"
      end
    end

    context "slug" do
      context "new" do
        before do
          @source = Source.new(@valid_params)
        end

        after do
          @source.destroy
        end

        test "on validation, not set" do
          assert_equal true, @source.valid?
          assert_equal nil, @source.slug
        end

        test "on save, set based on title" do
          assert_equal true, @source.save
          assert_equal "migratory-bird-flyways-continental-united-states", @source.slug
        end
      end

      context "create" do
        before do
          @source = Source.create(@valid_params)
        end

        after do
          @source.destroy
        end

        test "set based on title" do
          assert_equal "migratory-bird-flyways-continental-united-states", @source.slug
        end
      end

      context "update" do
        before do
          @source = Source.new(@valid_params)
        end

        after do
          @source.destroy
        end

        test "unchanged after multiple saves" do
          @source.save
          assert_equal "migratory-bird-flyways-continental-united-states", @source.slug
          @source.save
          assert_equal "migratory-bird-flyways-continental-united-states", @source.slug
        end

        test "disallow duplicate slugs" do
          @source.slug = "in-use"
          @source.save
          @new_source = Source.new(@valid_params)
          @new_source.slug = "in-use"
          assert_equal false, @new_source.valid?
          expected = { :slug => ["has already been taken"] }
          assert_equal expected, @new_source.errors.errors
        end

        test "prevent duplicate slugs" do
          params = @valid_params.merge(:title => "Common")
          @source = Source.create(params)

          source_2 = Source.create!(params)
          assert_equal "common-2", source_2.slug

          source_3 = Source.create!(params)
          assert_equal "common-3", source_3.slug

          source_2.destroy
          source_3.destroy
        end
      end
    end

    context "frequency" do
      INVALID_FREQUENCIES = %w(
        biweekly
        bimonthly
      )

      INVALID_FREQUENCIES.each do |term|
        context "#{term} frequency" do
          before do
            @source = Source.new(@valid_params.merge(
              :frequency => term))
          end

          use "invalid source"
          use "source.frequency is invalid"
        end
      end

      VALID_FREQUENCIES = %w(
        weekly
        monthly
        quarterly
        biannually
        annually
        yearly
        unknown
      )

      VALID_FREQUENCIES.each do |term|
        context "#{term} frequency" do
          before do
            @source = Source.new(@valid_params.merge(
              :frequency => term))
          end

          use "valid source"
        end
      end
    end

    context "period" do
      context "period_start without period_end" do
        before do
          @source = Source.new(@valid_params.merge(
            :period_start => {
              "year"  => 2005,
              "month" => 7,
              "day"   => 21,
            }
          ))
        end

        use "invalid source"
      end

      context "period_end without period_start" do
        before do
          @source = Source.new(@valid_params.merge(
            :period_end => {
              "year"  => 2006,
              "month" => 4,
              "day"   => 20,
            }
          ))
        end

        use "invalid source"
      end

      context "period_end before period_start" do
        before do
          @source = Source.new(@valid_params.merge(
            :period_start => {
              "year"  => 2009,
              "month" => 3,
              "day"   => 1
            },
            :period_end => {
              "year"  => 2007,
              "month" => 3,
              "day"   => 5
            }
          ))
        end

        use "invalid source"
      end

      context "period_start before period_end" do
        before do
          @source = Source.new(@valid_params.merge(
            :period_start => {
              "year"  => 2007,
              "month" => 3,
              "day"   => 5,
            },
            :period_end => {
              "year"  => 2009,
              "month" => 3,
              "day"   => 1,
            }
          ))
        end

        use "valid source"
      end

      # TODO: See Pivotal Ticket #2732426
      # context "period with strings" do
      #   before do
      #     @source = Source.new(@valid_params.merge(
      #       :period_start => "2009",
      #       :period_end   => "2011"
      #     ))
      #   end
      #
      #   use "invalid source"
      # end
    end

    context "url" do
      context "missing" do
        before do
          @source = Source.new(@valid_params.merge(:url => ""))
        end

        use "invalid source"
        use "source.url can't be empty"
      end

      context "http with port" do
        before do
          @source = Source.new(@valid_params.merge(
            :url => "http://www.data.gov:80/details/12"))
        end

        use "valid source"
      end

      context "ftp" do
        before do
          @source = Source.new(@valid_params.merge(
            :url => "ftp://data.gov/12"))
        end

        use "valid source"
      end

      context "https" do
        before do
          @source = Source.new(@valid_params.merge(
            :url => "https://sekret.com/1999"))
        end

        use "valid source"
      end

      context "relative" do
        before do
          @source = Source.new(@valid_params.merge(
           :url => "/source/1999"))
        end

        use "invalid source"
        use "source.url must be absolute"
      end

      context "wacky" do
        before do
          @source = Source.new(@valid_params.merge(
            :url => "wacky://sekret.com/1999"))
        end

        use "invalid source"
        use "source.url must be http, https, or ftp"
      end
    end

    context "released" do
      context "missing" do
        before do
          @source = Source.new(@valid_params.merge(:released => ''))
        end

        use "valid source"

        test "should have empty hash for released" do
          @source.valid?
          assert_equal({}, @source.released)
        end
      end

      context "too large of a year" do
        before do
          @source = Source.new(@valid_params.merge(
            :released => { :year => "2050" }
          ))
        end

        test "should have error on released" do
          @source.valid?
          assert_include :released, @source.errors.errors
          actual = @source.errors.errors[:released]
          assert_include "year must be between 1900 and 2010", actual
        end
      end

      context "noninteger month" do
        before do
          @source = Source.new(@valid_params.merge(
            :released => { :month => "February" }
          ))
        end

        test "should have errors on released" do
          @source.valid?
          assert_include :released, @source.errors.errors
          actual = @source.errors.errors[:released]
          assert_include "month must be an integer if present", actual
          assert_include "month must be between 1 and 12", actual
        end
      end

      context "too large of a day" do
        before do
          @source = Source.new(@valid_params.merge(
            :released => { :day => 32 }
          ))
        end

        test "should have errors on released" do
          @source.valid?
          assert_include :released, @source.errors.errors
          actual = @source.errors.errors[:released]
          assert_include "day must be between 1 and 31", actual
        end
      end

      test "year only" do
        @source = Source.new(@valid_params.merge(
          :released => { :year => 2008 }
        ))
        assert_equal true, @source.valid?
      end

      test "year, month only" do
        @source = Source.new(@valid_params.merge(
          :released => { :year => 2008, :month => 4 }
        ))
        assert_equal true, @source.valid?
      end

      test "year, month, day only" do
        @source = Source.new(@valid_params.merge(
          :released => { :year => 2008, :month => 4, :day => 5 }
        ))
        assert_equal true, @source.valid?
      end

      test "month only" do
        @source = Source.new(@valid_params.merge(
          :released => { :month => 5 }
        ))
        assert_equal false, @source.valid?
        actual = @source.errors.errors[:released]
        assert_include "year required if month is present", actual
      end

      test "day only" do
        @source = Source.new(@valid_params.merge(
          :released => { :day => 12 }
        ))
        assert_equal false, @source.valid?
        actual = @source.errors.errors[:released]
        assert_include "year required if day is present", actual
        assert_include "month required if day is present", actual
      end
    end
  end

  context "timestamps" do
    before do
      @doc = create_source(
        :title => "Just Some Data",
        :url   => "http://original.gov"
      )
      @original = fields(@doc)
      Timecop.travel(1)
      @doc.url = "http://updated.gov"
      @doc.save!
      @updated = fields(@doc)
      Timecop.return
    end

    after do
      @doc.destroy
    end

    test "should have updated url" do
      assert_equal "http://updated.gov", @updated[:url]
    end

    test "should have an unchanged created_at" do
      assert_equal_mongo_times @original[:created_at], @updated[:created_at]
    end

    test "body should have an updated updated_at" do
      assert_different_mongo_times @original[:updated_at], @updated[:updated_at]
    end

    test "body should have an unchanged _id" do
      assert_equal @original[:id], @updated[:id]
    end

    def fields(doc)
      {
        :id         => doc._id,
        :url        => doc.url,
        :created_at => doc.created_at,
        :updated_at => doc.updated_at,
      }
    end
  end

  context "keywords" do
    context "no organization" do
      before do
        @source = create_source(
          :title       => "Campaign Contributions for 2008",
          :url         => "http://fec.gov/data",
          :description => "This data set contains campaign contributions for the year 2008."
        )
      end

      test "correct keywords" do
        assert_equal %w(
          2008
          campaign
          contains
          contributions
          year
        ), @source._keywords.sort
      end
    end

    context "with organization" do
      before do
        @organization = create_organization({
          :name        => "Environmental Protection Agency",
          :acronym     => "EPA",
          :names       => ["Environmental Protection Agency"],
          :description => "The mission of EPA is to protect human health and to safeguard the natural environment -- air, water and land -- upon which life depends.",
        })
        @source = create_source({
          :title           => "Campaign Contributions for 2008",
          :url             => "http://fec.gov/data",
          :description     => "This data set contains campaign contributions for the year 2008.",
          :organization_id => @organization.id,
        })
      end

      test "correct keywords" do
        assert_equal %w(
          2008
          agency
          campaign
          contains
          contributions
          environmental
          epa
          protection
          year
        ), @source._keywords.sort
      end
    end
  end

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

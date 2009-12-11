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

  shared "source.source_type must be api or dataset" do
    test "should be invalid when not 'api' or 'dataset'" do
      @source.valid?
      assert_include :source_type, @source.errors.errors
      assert_equal ["must be one of: api, dataset"],
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

  shared "source.url must be http or ftp" do
    test "should have error on url - must be http or ftp" do
      @source.valid?
      assert_include :url, @source.errors.errors
      assert_include "URI scheme must be http or ftp", @source.errors.errors[:url]
    end
  end
  
  shared "source.frequency is invalid" do
    test "" do
      @source.valid?
      assert_include :frequency, @source.errors.errors
      assert_include "is invalid", @source.errors.errors[:frequency]
    end
  end

  shared "source.period_start is invalid" do
    test "" do
      @source.valid?
      assert_include :period_start, @source.errors.errors
      assert_include "is invalid", @source.errors.errors[:period_start]
    end
  end

  shared "source.period_end is invalid" do
    test "" do
      @source.valid?
      assert_include :period_end, @source.errors.errors
      assert_include "is invalid", @source.errors.errors[:period_end]
    end
  end

  context "Source.new" do
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
        use "source.source_type must be api or dataset"
      end
      
      context "invalid" do
        before do
          @source = Source.new(@valid_params.merge(:source_type => "foobar"))
        end

        use "invalid source"
        use "source.source_type must be api or dataset"
      end
    end
    
    context "slug" do
      context "Source without title" do
        before do
          @source = Source.new(@valid_params.delete_if { |k, v| k == :title })
        end
        
        test "do not set slug if title blank" do
          assert_equal false, @source.valid?
          assert_equal nil, @source.slug
        end
        
        test "set slug after title is set and source saved" do
          @source.title = "Wetlands Protection"
          assert_equal true, @source.save
          assert_equal "wetlands-protection", @source.slug
        end
      end
      
      context "Source with valid params" do
        before do
          @source = Source.new(@valid_params)
        end
      
        test "should save when explicitly set" do
          @source.slug = "my-awesome-slug"
          @source.save
          assert_equal "my-awesome-slug", @source.slug
        end

        test "should generate something when title has no valid characters" do
          @source.title = "%+*"
          @source.save
          assert_not_equal "", @source.slug
        end

        test "should be invalid on bad characters" do
          @source.slug = "%+*"
          @source.save
          assert_include :slug, @source.errors.errors
          assert_include "can only contain alphanumeric characters and dashes", @source.errors.errors[:slug]
        end

        test "should save only alphanumeric characters from title" do
          @source.title = "My Custom Title!%&+!"
          @source.save
          assert_equal "my-custom-title", @source.slug
        end
              
        test "should stay the same after multiple saves" do
          @source.title = "Stay the Same!"
          @source.save
          assert_equal "stay-the-same", @source.slug
          @source.save
          assert_equal "stay-the-same", @source.slug
        end

        test "should not allow duplicate slug" do
          @source.slug = "in-use"
          @source.save
          @new_source = Source.new(@valid_params)
          @new_source.slug = "in-use"
          assert_equal false, @new_source.valid?
          expected = { :slug => ["has already been taken"] }
          assert_equal expected, @new_source.errors.errors
        end

        test "should prevent duplicate slugs" do
          @source.title = "Common Title"
          @source.save

          s = Source.new(@valid_params)
          s.title = "Common Title"
          assert_equal true, s.save
          assert_equal "common-title-2", s.slug
          assert_equal true, s.valid?

          s = Source.new(@valid_params)
          s.title = "Common Title"
          assert_equal true, s.save
          assert_equal "common-title-3", s.slug
          assert_equal true, s.valid?
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
            :period_start => Time.local(2009, 3, 1)
          ))
        end
  
        use "invalid source"
      end
  
      context "period_end without period_start" do
        before do
          @source = Source.new(@valid_params.merge(
            :period_end   => Time.local(2007, 3, 5)
          ))
        end
  
        use "invalid source"
      end
  
      context "period_end before period_start" do
        before do
          @source = Source.new(@valid_params.merge(
            :period_start => Time.local(2009, 3, 1),
            :period_end   => Time.local(2007, 3, 5)
          ))
        end
  
        use "invalid source"
      end
  
      context "period_start before period_end" do
        before do
          @source = Source.new(@valid_params.merge(
            :period_start => Time.local(2007, 3, 5),
            :period_end   => Time.local(2009, 3, 1)
          ))
        end
  
        use "valid source"
      end
  
      # PENDING
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
  
        use "invalid source"
        use "source.url must be http or ftp"
      end
  
      context "relative" do
        before do
          @source = Source.new(@valid_params.merge(
           :url => "/source/1999"))
        end
  
        use "invalid source"
        use "source.url must be absolute"
      end
    end

    context "released" do
      context "missing" do
        before do
          @source = Source.new(@valid_params.merge(:released => ""))
        end
  
        use "valid source"
        
        test "should have empty hash for released" do
          @source.valid?
          assert_equal({}, @source.released)
        end
      end

      context "noninteger year" do
        before do
          @source = Source.new(@valid_params.merge(
            :released => { :year => "2004" }
          ))
        end
        
        test "should have error on released" do
          @source.valid?
          assert_include :released, @source.errors.errors
          actual = @source.errors.errors[:released]
          assert_include "year must be an integer if present", actual
          assert_include "year must be between 1900 and 2009", actual
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

      context "noninteger day" do
        before do
          @source = Source.new(@valid_params.merge(
            :released => { :day => "20" }
          ))
        end
        
        test "should have errors on released" do
          @source.valid?
          assert_include :released, @source.errors.errors
          actual = @source.errors.errors[:released]
          assert_include "day must be an integer if present", actual
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
      doc = create_source(
        :title => "Just Some Data",
        :url   => "http://original.gov"
      )
      @original_id = doc._id
      @original_created_at = doc.created_at
      @original_updated_at = doc.updated_at
      Timecop.travel(1)
      doc.url = "http://updated.gov"
      doc.save
      @updated = doc
      Timecop.return
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
  
  context "keywords" do
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
    
end

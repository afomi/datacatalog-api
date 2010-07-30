require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class CatalogUnitTest < ModelTestCase

  shared "valid catalog" do
    test "should be valid" do
      assert_equal true, @catalog.valid?
    end
  end

  shared "invalid catalog" do
    test "should not be valid" do
      assert_equal false, @catalog.valid?
    end
  end

  shared "catalog.url can't be empty" do
    test "should have error on url - can't be empty" do
      @catalog.valid?
      assert_include :url, @catalog.errors.errors
      assert_include "can't be empty", @catalog.errors.errors[:url]
    end
  end

  shared "catalog.url must be absolute" do
    test "should have error on url - must be absolute" do
      @catalog.valid?
      assert_include :url, @catalog.errors.errors
      assert_include "URI must be absolute", @catalog.errors.errors[:url]
    end
  end

  shared "catalog.url must be http, https, or ftp" do
    test "should have error on url - must be http, https, or ftp" do
      @catalog.valid?
      assert_include :url, @catalog.errors.errors
      assert_include "URI scheme must be http, https, or ftp", @catalog.errors.errors[:url]
    end
  end

  context "Catalog" do
    before do
      @valid_params = {
        :title       => "Data.gov",
        :url         => "http://www.data.gov",
      }
    end

    context "correct params" do
      before do
        @catalog = Catalog.new(@valid_params)
      end

      use "valid catalog"
    end

    context "title" do
      context "missing" do
        before do
          @catalog = Catalog.new(@valid_params.merge(:title => ""))
        end

        use "invalid catalog"
      end
    end

    context "url" do
      context "missing" do
        before do
          @catalog = Catalog.new(@valid_params.merge(:url => ""))
        end

        use "invalid catalog"
        use "catalog.url can't be empty"
      end

      context "http with port" do
        before do
          @catalog = Catalog.new(@valid_params.merge(
            :url => "http://www.data.gov:80/details/12"))
        end

        use "valid catalog"
      end

      context "ftp" do
        before do
          @catalog = Catalog.new(@valid_params.merge(
            :url => "ftp://data.gov/12"))
        end

        use "valid catalog"
      end

      context "https" do
        before do
          @catalog = Catalog.new(@valid_params.merge(
            :url => "https://sekret.com/1999"))
        end

        use "valid catalog"
      end

      context "relative" do
        before do
          @catalog = Catalog.new(@valid_params.merge(
           :url => "/catalog/1999"))
        end

        use "invalid catalog"
        use "catalog.url must be absolute"
      end

      context "wacky" do
        before do
          @catalog = Catalog.new(@valid_params.merge(
            :url => "wacky://sekret.com/1999"))
        end

        use "invalid catalog"
        use "catalog.url must be http, https, or ftp"
      end
    end
  end

end

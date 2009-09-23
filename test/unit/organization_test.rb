require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class OrganizationUnitTest < ModelTestCase

  shared "valid organization" do
    test "should be valid" do
      assert_equal true, @organization.valid?
    end
  end

  shared "invalid organization" do
    test "should not be valid" do
      assert_equal false, @organization.valid?
    end
  end

  shared "organization.name can't be empty" do
    test "should have error on text" do
      @organization.valid?
      assert_include :name, @organization.errors.errors
      assert_include "can't be empty", @organization.errors.errors[:name]
    end
  end

  shared "organization.url must be absolute" do
    test "should have error on url - must be absolute" do
      @organization.valid?
      assert_include :url, @organization.errors.errors
      assert_include "URI must be absolute", @organization.errors.errors[:url]
    end
  end

  shared "organization.url must be http or ftp" do
    test "should have error on url - must be http or ftp" do
      @organization.valid?
      assert_include :url, @organization.errors.errors
      assert_include "URI scheme must be http or ftp", @organization.errors.errors[:url]
    end
  end

  # - - - - - - - - - -
  
  context "Organization.new" do
    before do
      @valid_params = {
        :name => "Department of Commerce"
      }
    end
    
    context "correct params" do
      before do
        @organization = Organization.new(@valid_params)
      end
      
      use "valid organization"
    end

    context "missing name" do
      before do
        @organization = Organization.new(@valid_params.merge(:name => ""))
      end
      
      use "invalid organization"
      use "organization.name can't be empty"
    end

    context "url" do
      context "http with port" do
        before do
          @organization = Organization.new(@valid_params.merge(
            :url => "http://www.commerce.gov:80"))
        end

        use "valid organization"
      end

      context "ftp" do
        before do
          @organization = Organization.new(@valid_params.merge(
            :url => "ftp://commerce.gov"))
        end

        use "valid organization"
      end

      context "https" do
        before do
          @organization = Organization.new(@valid_params.merge(
            :url => "https://commerce.gov"))
        end

        use "invalid organization"
        use "organization.url must be http or ftp"
      end

      context "relative" do
        before do
          @organization = Organization.new(@valid_params.merge(
           :url => "/just/a/path"))
        end

        use "invalid organization"
        use "organization.url must be absolute"
      end
    end
  end

end

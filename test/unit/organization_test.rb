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
  
  context "Organization" do
    before do
      @valid_params = {
        :name     => "Department of Commerce",
        :org_type => "governmental"
      }
    end
  
    context "missing name" do
      before do
        @organization = Organization.new(@valid_params.merge(:name => ""))
      end
      
      use "invalid organization"
      use "organization.name can't be empty"
    end

    context "incorrect org_type" do
      before do
        @organization = Organization.new(@valid_params.merge(
          :org_type => "big"))
      end
      
      use "invalid organization"
      
      test "invalid org_type" do
        @organization.valid?
        expected = { :org_type => [
          "must be one of: commercial, governmental, not-for-profit"] }
        assert_equal expected, @organization.errors.errors
      end
    end
    
    context "correct params" do
      before do
        @organization = Organization.new(@valid_params)
      end
      
      use "valid organization"
    end
    
    context "slug" do
      
      context "creation" do 
        before do
          @organization = Organization.new(
            :name     => "Department of State",
            :org_type => "governmental"
          )
        end
      
        test "do not set slug if name blank" do
          @organization.name = ""
          assert_equal false, @organization.valid?
          assert_equal nil, @organization.slug
        end
        
        test "set slug to title when using create" do
          @organization = Organization.create(
            :name     => "Department of Justice",
            :org_type => "governmental",
            :slug     => ""
          )
          assert_equal "department-of-justice", @organization.slug
        end
          
        test "set slug to acronym if acronym is set" do
          @organization.acronym = "DOS"
          assert_equal true, @organization.save
          assert_equal "dos", @organization.slug
        end  
          
        test "set slug to name if name is set but not acronym" do
          @organization.acronym = ""
          assert_equal true, @organization.save
          assert_equal "department-of-state", @organization.slug
        end
      end
      
      context "update" do
        before do
          @organization = Organization.new(
            :name     => "Department of Agriculture",
            :org_type => "governmental",
            :acronym  => "USDA"
          )
          end
        
          test "should stay the same after multiple saves" do
            @organization.save
            assert_equal "usda", @organization.slug
            @organization.save
            assert_equal "usda", @organization.slug
          end
          
          test "should not allow duplicate slug" do
            @organization.slug = "in-use"
            @organization.save
            @new_organization = Organization.new(@valid_params)
            @new_organization.slug = "in-use"
            assert_equal false, @new_organization.valid?
            expected = { :slug => ["has already been taken"] }
            assert_equal expected, @new_organization.errors.errors
          end
          
        test "should prevent duplicate slugs" do
          @organization.name = "Common Name"
          @organization.acronym = ""
          @organization.save
        
          o2 = Organization.new(@valid_params)
          o2.name = "Common Name"
          assert_equal true, o2.save
          assert_equal "common-name-2", o2.slug
          assert_equal true, o2.valid?
        
          o3 = Organization.new(@valid_params)
          o3.name = "Common Name"
          assert_equal true, o3.save
          assert_equal "common-name-3", o3.slug
          assert_equal true, o3.valid?
        end
      end
      
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

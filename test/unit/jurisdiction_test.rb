require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class JurisdictionUnitTest < ModelTestCase

  shared "valid jurisdiction" do
    test "should be valid" do
      assert_equal true, @jurisdiction.valid?
    end
  end

  shared "invalid jurisdiction" do
    test "should not be valid" do
      assert_equal false, @jurisdiction.valid?
    end
  end

  shared "jurisdiction.name can't be empty" do
    test "should have error on text" do
      @jurisdiction.valid?
      assert_include :name, @jurisdiction.errors.errors
      assert_include "can't be empty", @jurisdiction.errors.errors[:name]
    end
  end

  shared "jurisdiction.url must be absolute" do
    test "should have error on url - must be absolute" do
      @jurisdiction.valid?
      assert_include :url, @jurisdiction.errors.errors
      assert_include "URI must be absolute", @jurisdiction.errors.errors[:url]
    end
  end

  shared "jurisdiction.url must be http or ftp" do
    test "should have error on url - must be http or ftp" do
      @jurisdiction.valid?
      assert_include :url, @jurisdiction.errors.errors
      assert_include "URI scheme must be http or ftp", @jurisdiction.errors.errors[:url]
    end
  end
  
  context "jurisdiction" do
    before do
      @valid_params = {
        :name     => "Federal Government"
      }
    end
  
    context "missing name" do
      before do
        @jurisdiction = Jurisdiction.new(@valid_params.merge(:name => ""))
      end
      
      use "invalid jurisdiction"
      use "jurisdiction.name can't be empty"
    end
  
    context "correct params" do
      before do
        @jurisdiction = Jurisdiction.new(@valid_params)
      end
      
      use "valid jurisdiction"
    end

    context "slug" do
      context "new" do 
        before do
          @jurisdiction = Jurisdiction.new(@valid_params)
        end

        after do
          @jurisdiction.destroy
        end

        test "on validation, not set" do
          assert_equal true, @jurisdiction.valid?
          assert_equal nil, @jurisdiction.slug
        end

        test "on save, set based on name" do
          assert_equal true, @jurisdiction.save
          assert_equal "federal-government", @jurisdiction.slug
        end
      end

      context "create" do
        before do
          @jurisdiction = Jurisdiction.create(@valid_params)
        end

        after do
          @jurisdiction.destroy
        end

        test "set based on name" do
          assert_equal "federal-government", @jurisdiction.slug
        end
      end

      context "update" do
        before do
          @jurisdiction = Jurisdiction.new(@valid_params)
        end

        after do
          @jurisdiction.destroy
        end

        test "unchanged after multiple saves" do
          @jurisdiction.save
          assert_equal "federal-government", @jurisdiction.slug
          @jurisdiction.save
          assert_equal "federal-government", @jurisdiction.slug
        end

        test "disallow duplicate slugs" do
          @jurisdiction.slug = "in-use"
          @jurisdiction.save
          @new_jurisdiction = Jurisdiction.new(@valid_params)
          @new_jurisdiction.slug = "in-use"
          assert_equal false, @new_jurisdiction.valid?
          expected = { :slug => ["has already been taken"] }
          assert_equal expected, @new_jurisdiction.errors.errors
        end

        test "prevent duplicate slugs" do
          params = @valid_params.merge(:name => "Common")
          @jurisdiction = Jurisdiction.create(params)
        
          jurisdiction_2 = Jurisdiction.create!(params)
          assert_equal "common-2", jurisdiction_2.slug
        
          jurisdiction_3 = Jurisdiction.create!(params)
          assert_equal "common-3", jurisdiction_3.slug
        
          jurisdiction_2.destroy
          jurisdiction_3.destroy
        end
      end
    end

    context "url" do
      context "http with port" do
        before do
          @jurisdiction = Jurisdiction.new(@valid_params.merge(
            :url => "http://www.usa.gov:80"))
        end
    
        use "valid jurisdiction"
      end
    
      context "ftp" do
        before do
          @jurisdiction = Jurisdiction.new(@valid_params.merge(
            :url => "ftp://usa.gov"))
        end
    
        use "valid jurisdiction"
      end
    
      context "https" do
        before do
          @jurisdiction = Jurisdiction.new(@valid_params.merge(
            :url => "https://usa.gov"))
        end
    
        use "invalid jurisdiction"
        use "jurisdiction.url must be http or ftp"
      end
    
      context "relative" do
        before do
          @jurisdiction = Jurisdiction.new(@valid_params.merge(
           :url => "/just/a/path"))
        end
    
        use "invalid jurisdiction"
        use "jurisdiction.url must be absolute"
      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceJurisdictionUnitTest < ModelTestCase

  context "source with no jurisdiction" do
    before do
      @organization = create_organization(
        :name     => "Department of Commerce",
        :org_type => "governmental"
      )
      @source = new_source(
        :title        => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url          => "http://www.data.gov/details/90",
        :organization => @organization
      )
    end
    
    test "#calculate_jurisdiction should be nil" do
      assert @source.calculate_jurisdiction.nil?
    end
    
    test "before save, #jurisdiction should be nil" do
      assert @source.calculate_jurisdiction.nil?
    end
    
    test "after save, #jurisdiction should be nil" do
      @source.save
      assert @source.jurisdiction.nil?
    end
  end
  
  context "source with a jurisdiction" do
    before do
      @jurisdiction = create_organization(
        :name      => "US Federal Government",
        :org_type  => "governmental",
        :top_level => true 
      )
      @organization = create_organization(
        :name      => "Department of Commerce",
        :org_type  => "governmental",
        :parent_id => @jurisdiction.id
      )
      @source = create_source(
        :title        => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url          => "http://www.data.gov/details/90",
        :organization => @organization
      )
    end
    test "after create, #jurisdiction should return correct organization" do
      assert_equal @jurisdiction, @source.jurisdiction
    end
  end
  
  context "source with a jurisdiction" do
    before do
      @jurisdiction = create_organization(
        :name      => "US Federal Government",
        :org_type  => "governmental",
        :top_level => true 
      )
      @organization = create_organization(
        :name      => "Department of Commerce",
        :org_type  => "governmental",
        :parent_id => @jurisdiction.id
      )
      @source = new_source(
        :title        => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url          => "http://www.data.gov/details/90",
        :organization => @organization
      )
    end

    test "#calculate_jurisdiction should return correct organization" do
      assert_equal @jurisdiction, @source.calculate_jurisdiction
    end

    test "before save, #jurisdiction should return nil" do
      assert @source.jurisdiction.nil?
    end

    test "after save, #jurisdiction should return correct organization" do
      @source.save
      assert_equal @jurisdiction, @source.jurisdiction
    end
    
    test "updating organization should update jurisdiction" do
      @new_jurisdiction = create_organization(
        :name      => "State of Arizona",
        :org_type  => "governmental",
        :top_level => true 
      )
      @new_organization = create_organization(
        :name      => "Department of Deserts",
        :org_type  => "governmental",
        :parent_id => @new_jurisdiction.id
      )
      @source.organization = @new_organization
      @source.save!
      assert_equal @new_jurisdiction, @source.jurisdiction
    end
  end

  context "source with a jurisdiction under a jurisdiction" do
    before do
      @california = create_organization(
        :name      => "State of California",
        :org_type  => "governmental",
        :top_level => true 
      )
      @san_francisco = create_organization(
        :name      => "City of San Francisco",
        :org_type  => "governmental",
        :top_level => true,
        :parent_id => @california.id
      )
      @human_services = create_organization(
        :name      => "Human Services Agency",
        :org_type  => "governmental",
        :href      => "http://www.sfhsa.org",
        :parent_id => @san_francisco.id
      )
      @source = new_source(
        :title        => "DAAS Intake monthly",
        :url          => "http://www.datasf.org/story.php?title=daas-intake-monthly",
        :organization => @human_services
      )
    end

    test "#calculate_jurisdiction should return proximate parent" do
      assert_equal @san_francisco, @source.calculate_jurisdiction
    end
  end

  
end
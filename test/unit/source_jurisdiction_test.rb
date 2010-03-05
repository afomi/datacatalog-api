require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceJurisdictionUnitTest < ModelTestCase

  context "source with no jurisdiction" do
    before do
      @organization = create_organization(
        :name     => "Department of Commerce",
        :org_type => "governmental"
      )
      @source = create_source(
        :title        => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url          => "http://www.data.gov/details/90",
        :organization => @organization
      )
    end
    
    test "#jurisdiction should be nil" do
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
    
    test "#jurisdiction should return correct organization" do
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
  
end
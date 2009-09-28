require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceOrganizationUnitTest < ModelTestCase
  
  context "source with no organization" do
    before do
      @source = Source.new(
        :title => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url   => "http://www.data.gov/details/90"
      )
    end
    
    test "#organization should be nil" do
      assert @source.organization.nil?
    end
  end

  context "source with an organization" do
    before do
      @organization = Organization.create(
        :name => "Department of Commerce"
      )
      @source = Source.create(
        :title        => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url          => "http://www.data.gov/details/90",
        :organization => @organization
      )
    end
    
    test "#organization should return the organization" do
      assert_equal @organization, @source.organization
    end
  end
  
end

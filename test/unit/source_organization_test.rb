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
      @organization = create_organization(
        :name     => "Department of Commerce",
        :org_type => "governmental"
      )
      @source = create_source(
        :title        => "2005-2007 American Community Survey Three-Year PUMS Housing File",
        :url          => "http://www.data.gov/details/90",
        :organization => @organization
      )
      @organization = @organization.reload
    end
    
    test "#organization should return the organization" do
      assert_equal @organization, @source.organization
    end
    
    test "#sources and @source_count should be correct" do
      assert_equal [@source], @organization.sources
      assert_equal 1, @organization.source_count
    end
    
    context "adding another organization" do
      before do
        @source_2 = create_source(
          :title        => "Unverifed List of Foreign Persons Red Flagged for Exporting Actions",
          :url          => "http://www.data.gov/details/995",
          :organization => @organization
        )
        @organization = @organization.reload
      end
    
      test "#sources and @source_count should be correct" do
        assert_include @source_2, @organization.sources
        assert_equal 2, @organization.source_count
      end
    end
    
    context "changing the organization's source" do
      before do
        @organization_2 = create_organization(
          :name     => "Department of Transportation",
          :org_type => "governmental"
        )
        @source.organization = @organization_2
        @source.save!
        @organization = @organization.reload
        @organization_2 = @organization_2.reload
      end
    
      test "#sources and @source_count should be correct (a)" do
        assert_equal [], @organization.sources
        assert_equal 0, @organization.source_count
        assert_equal [@source], @organization_2.sources
        assert_equal 1, @organization_2.source_count
      end
    end
    
    context "removing the source" do
      before do
        @source.destroy
        @organization = @organization.reload
      end
    
      test "#sources and @source_count should be correct" do
        assert_equal [], @organization.sources
        assert_equal 0, @organization.source_count
      end
    end
    
  end
  
end

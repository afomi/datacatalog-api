require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class OrganizationAssociationsUnitTest < ModelTestCase
  
  context "Organization.create" do
    before do
      @parent_organization = create_organization({
        :name        => "Department of Health and Human Services",
        :acronym     => "HHS",
        :description => "The mission of HHS is...",
      })
      @child_organization = create_organization({
        :name        => "National Institutes of Health",
        :acronym     => "NIH",
        :description => "The mission of NIH is...",
        :parent_id   => @parent_organization.id,
      })
    end
    
    after do
      @child_organization.destroy
      @parent_organization.destroy
    end

    test "organizations should be valid" do
      assert @parent_organization.valid?
      assert @child_organization.valid?
    end
    
    test "organization.parent should be correct" do
      assert_equal @parent_organization, @child_organization.parent
    end

    test "organization.children should be correct" do
      children = @parent_organization.children.all
      assert_equal 1, children.length
      assert_include @child_organization, children
    end
  end
  
end

require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class OrganizationAssociationsUnitTest < ModelTestCase

  context "Organization.create" do
    before do
      @parent = Organization.create!({
        :name        => "Department of Health and Human Services",
        :acronym     => "HHS",
        :top_level   => true,
        :description => "The mission of HHS is...",
        :org_type    => "governmental",
        :top_level   => true,
      })
      @child = Organization.create!({
        :name        => "National Institutes of Health",
        :acronym     => "NIH",
        :description => "The mission of NIH is...",
        :org_type    => "governmental",
        :parent_id   => @parent.id,
      })
    end

    after do
      @child.destroy
      @parent.destroy
    end

    test "organizations should be valid" do
      assert @parent.valid?
      assert @child.valid?
    end

    test "organization.parent should be correct" do
      assert_equal @parent, @child.parent
    end

    test "organization.children should be correct" do
      children = @parent.children.all
      assert_equal 1, children.length
      assert_include @child, children
    end
  end

end

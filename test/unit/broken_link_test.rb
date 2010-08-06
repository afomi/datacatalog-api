require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class BrokenLinkUnitTest < ModelTestCase

  shared "valid broken_link" do
    test "should be valid" do
      assert_equal true, @broken_link.valid?
    end
  end

  shared "invalid broken_link" do
    test "should not be valid" do
      assert_equal false, @broken_link.valid?
    end
  end

  shared "source or organization reference required" do
    test "should have associated source or organization" do
      @broken_link.valid?
      assert_include :base, @broken_link.errors.errors
      assert_include "source_id or organization_id needed",
        @broken_link.errors.errors[:base]
    end
  end
  
  shared "references to both source and organization not allowed" do
    test "should not have associated source and organization" do
      @broken_link.valid?
      assert_include :base, @broken_link.errors.errors
      assert_include "source_id and organization_id cannot both be set",
        @broken_link.errors.errors[:base]
    end
  end

  shared "broken_link.field can't be empty" do
    test "should have error on field" do
      @broken_link.valid?
      assert_include :field, @broken_link.errors.errors
      assert_include "can't be empty", @broken_link.errors.errors[:field]
    end
  end

  shared "broken_link.destination_url can't be empty" do
    test "should have error on destination_url" do
      @broken_link.valid?
      assert_include :destination_url, @broken_link.errors.errors
      assert_include "can't be empty", @broken_link.errors.errors[:destination_url]
    end
  end

  shared "broken_link.status can't be empty" do
    test "should have error on status" do
      @broken_link.valid?
      assert_include :status, @broken_link.errors.errors
      assert_include "can't be empty", @broken_link.errors.errors[:status]
    end
  end

  context "BrokenLink (source)" do
    before do
      @source = create_source
      @valid_params = {
        :source_id       => @source.id,
        :field           => "documentation_url",
        :destination_url => "http://broken-link.gov/1002",
        :status          => 404,
        :last_checked    => Time.parse('2010-07-22'),
        :broken_since    => Time.parse('2010-07-15'),
      }
    end

    after do
      @source.destroy
    end

    context "missing source_id" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:source_id => nil))
      end

      use "invalid broken_link"
      use "source or organization reference required"
    end

    context "with organization_id" do
      before do
        @organization = create_organization
        @broken_link = BrokenLink.new(@valid_params.merge(
          :organization_id => @organization.id))
      end
      
      after do
        @organization.destroy
      end

      use "invalid broken_link"
      use "references to both source and organization not allowed"
    end

    context "missing field" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:field => nil))
      end

      use "invalid broken_link"
      use "broken_link.field can't be empty"
    end

    context "missing destination_url" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:destination_url => nil))
      end

      use "invalid broken_link"
      use "broken_link.destination_url can't be empty"
    end

    context "missing status" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:status => nil))
      end

      use "invalid broken_link"
      use "broken_link.status can't be empty"
    end
    
    context "correct params" do
      before do
        @broken_link = BrokenLink.new(@valid_params)
      end

      use "valid broken_link"
    end
  end

  context "BrokenLink (organization)" do
    before do
      @organization = create_source
      @valid_params = {
        :organization_id => @organization.id,
        :field           => "documentation_url",
        :destination_url => "http://broken-link.gov/1002",
        :status          => 404,
        :last_checked    => Time.parse('2010-07-22'),
        :broken_since    => Time.parse('2010-07-15'),
      }
    end

    context "missing organization_id" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:organization_id => nil))
      end

      use "invalid broken_link"
      use "source or organization reference required"
    end

    context "with source_id" do
      before do
        @source = create_source
        @broken_link = BrokenLink.new(@valid_params.merge(
          :source_id => @source.id))
      end
      
      after do
        @source.destroy
      end

      use "invalid broken_link"
      use "references to both source and organization not allowed"
    end

    context "missing field" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:field => nil))
      end

      use "invalid broken_link"
      use "broken_link.field can't be empty"
    end

    context "missing destination_url" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:destination_url => nil))
      end

      use "invalid broken_link"
      use "broken_link.destination_url can't be empty"
    end

    context "missing status" do
      before do
        @broken_link = BrokenLink.new(@valid_params.merge(:status => nil))
      end

      use "invalid broken_link"
      use "broken_link.status can't be empty"
    end

    context "correct params" do
      before do
        @broken_link = BrokenLink.new(@valid_params)
      end

      use "valid broken_link"
    end
  end

end

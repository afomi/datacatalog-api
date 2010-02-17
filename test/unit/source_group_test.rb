require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceGroupUnitTest < ModelTestCase

  shared "valid source_group" do
    test "should be valid" do
      assert_equal true, @source_group.valid?
    end
  end

  shared "invalid source_group" do
    test "should not be valid" do
      assert_equal false, @source_group.valid?
    end
  end

  shared "source_group.title can't be empty" do
    test "should have error on title" do
      @source_group.valid?
      assert_include :title, @source_group.errors.errors
      assert_include "can't be empty", @source_group.errors.errors[:title]
    end
  end

  # - - - - - - - - - -
  
  context "SourceGroup" do
    before do
      @valid_params = {
        :title => "2005 Toxics Release Inventory"
      }
    end
    
    context "correct params" do
      before do
        @source_group = SourceGroup.new(@valid_params)
      end
      
      use "valid source_group"
    end

    context "missing name" do
      before do
        @source_group = SourceGroup.new(@valid_params.merge(:title => ""))
      end
      
      use "invalid source_group"
      use "source_group.title can't be empty"
    end
  end

  # - - - - - - - - - -
  
  def create_example_sources
    sources = []
    sources << create_source(
      :title => "2005 Toxics Release Inventory data for the state of Texas",
      :url   => "http://www.data.gov/details/182"
    )
    sources << create_source(
      :title => "2005 Toxics Release Inventory data for the state of Utah",
      :url   => "http://www.data.gov/details/183"
    )
    sources << create_source(
      :title => "2005 Toxics Release Inventory data for the state of Virginia",
      :url   => "http://www.data.gov/details/184"
    )
    sources
  end

  # The point here is to demonstrate a low-level way to add SourceSnippets
  # to a SourceGroup. I don't recommend using this style in your code.
  context "Adding SourceSnippets to a SourceGroup" do
    before do
      @source_group = SourceGroup.new({
        :title       => "2005 Toxics Release Inventory data",
        :description => "A grouping of all states that reported 2005 Toxics Release Inventory data",
      })
      @sources = create_example_sources
      @source_group.source_snippets = @sources.map do |source|
        SourceSnippet.new_from_source(source)
      end
      @source_group.save!
    end
    
    after do
      @source_group.destroy
      @sources.each { |x| x.destroy }
    end
    
    test "correct titles" do
      states = %w(Texas Utah Virginia)
      expected_titles = states.map do |state|
        "2005 Toxics Release Inventory data for the state of #{state}"
      end
      titles = @source_group.source_snippets.map { |x| x.title }
      expected_titles.each do |expected_title|
        assert_include expected_title, titles
      end
    end
    
    test "sources do not point to source_group" do
      @sources.each do |source|
        assert_nil source.source_group_id
      end
    end
  end

  # - - - - - - - - - -

  # The point here is to demonstrate a more streamlined way to add Sources
  # to a SourceGroup. I do recommend using this style in your code.
  context "Adding Sources to a SourceGroup" do
    before do
      @source_group = SourceGroup.new({
        :title       => "2005 Toxics Release Inventory data",
        :description => "A grouping of all states that reported 2005 Toxics Release Inventory data",
      })
      @sources = create_example_sources
      @source_group.sources = @sources
      @source_group.save!
    end

    after do
      @source_group.destroy
      @sources.each { |x| x.destroy }
    end
    
    test "correct titles" do
      states = %w(Texas Utah Virginia)
      expected_titles = states.map do |state|
        "2005 Toxics Release Inventory data for the state of #{state}"
      end
      titles = @source_group.source_snippets.map { |x| x.title }
      expected_titles.each do |expected_title|
        assert_include expected_title, titles
      end
    end
    
    test "sources point to source_group" do
      @sources.each do |source|
        assert_equal @source_group, source.source_group
      end
    end
    
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../test_resource_helper')

class SluggableUnitTest < Test::Unit::TestCase

  context "Slug.make" do
    class Document; end
    
    before do
      @doc = Document.new
      stub(@doc).id { 42 }
    end

    test "example 1" do
      stub(@doc).slug { "" }
      stub(Document).first(:slug => "the-great-data") { nil }
      assert_equal "the-great-data", Slug.make("The Great Data", @doc)
    end
    
    test "example 2" do
      stub(@doc).slug { "the-great-data" }
      stub(Document).first(:slug => "the-great-data") { @doc }
      stub(Document).first(:slug => "the-great-data-2") { nil }
      assert_equal "the-great-data-2", Slug.make("The Great Data", @doc)
    end

    test "example 3" do
      stub(@doc).slug { "the-great-data" }
      @doc_2 = Document.new
      stub(@doc_2).id { 43 }
      stub(Document).first(:slug => "the-great-data") { @doc }
      stub(Document).first(:slug => "the-great-data-2") { @doc_2 }
      stub(Document).first(:slug => "the-great-data-3") { nil }
      assert_equal "the-great-data-3", Slug.make("The Great Data", @doc)
    end
  end

  context "Slug.make_prefix" do
    class Document; end

    before do
      @doc = Document.new
      stub(@doc).id { 42 }
    end
  
    test "alphanumeric string" do
      assert_equal "the-great-data", Slug.make_prefix("The Great Data", @doc)
    end
  
    test "alphanumeric string, custom separator" do
      assert_equal "the.great.data", Slug.make_prefix("The Great Data", @doc, '.')
    end
  
    test "string with hyphen and comma" do
      title = "2008 Mexican Yellow-Tailed Bat Population in Austin, TX"
      expected = "2008-mexican-yellow-tailed-bat-population-in-austin-tx"
      assert_equal expected, Slug.make_prefix(title, @doc)
    end
    
    test "empty string with doc id fallback" do
      assert_equal "42", Slug.make_prefix("", @doc)
    end
    
    test "empty string with nil fallback" do
      assert_not_equal "", Slug.make_prefix("", @doc)
    end
  
    test "string with weird characters" do
      assert_equal "42", Slug.make_prefix('!!!@!!!', @doc)
    end
    
    test "should generate something when title has no valid characters" do
      actual = Slug.make_prefix("%+*", @doc)
      assert_not_equal "", actual
    end
  end

end
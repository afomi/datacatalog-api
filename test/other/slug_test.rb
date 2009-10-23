require File.expand_path(File.dirname(__FILE__) + '/../test_controller_helper')

class SluggableUnitTest < Test::Unit::TestCase

  before do
    @doc = Object.new
  end
  
  context "Slug.make" do
    test "alphanumeric string" do
      assert_equal "the-great-data", Slug.make("The Great Data", @doc)
    end

    test "alphanumeric string, custom separator" do
      assert_equal "the.great.data", Slug.make("The Great Data", @doc, '.')
    end

    test "string with hyphen and comma" do
      title = "2008 Mexican Yellow-Tailed Bat Population in Austin, TX"
      expected = "2008-mexican-yellow-tailed-bat-population-in-austin-tx"
      assert_equal expected, Slug.make(title, @doc)
    end
    
    test "empty string with doc id fallback" do
      mock(@doc).id { 42 }
      assert_equal "42", Slug.make("", @doc)
    end
    
    test "empty string with nil fallback" do
      mock(@doc).id { nil }
      assert_not_equal "", Slug.make("", @doc)
    end

    test "string with weird characters" do
      mock(@doc).id { 42 }
      assert_equal "42", Slug.make('!!!@!!!', @doc)
    end
  end

end
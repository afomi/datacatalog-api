require File.expand_path(File.dirname(__FILE__) + '/../test_resource_helper')

class SearchUnitTest < Test::Unit::TestCase
  include DataCatalog

  context "tokens" do
    test "spaces" do
      assert_equal %w(hello world), Search.tokens("hello world")
    end

    test "commas" do
      assert_equal %w(red white blue), Search.tokens("red, white, blue")
    end

    test "periods" do
      assert_equal %w(flood plain data), Search.tokens("Flood plain data.")
    end

    test "integers" do
      assert_equal %w(99 barrels of beer), Search.tokens("99 barrels of beer")
    end

    test "floating point" do
      assert_equal %w(the earth has an axial tilt of 23.439 degrees),
        Search.tokens("The earth has an axial tilt of 23.439 degrees.")
    end
  end
  
  test "tokenize" do
    assert_equal %w(aerospace defense systems),
      Search.tokenize(["aerospace defense", "defense systems"])
  end
  
  test "unstop" do
    assert_equal %w(big brown fox jumped),
      Search.unstop(%w(the big brown fox jumped))
    assert_equal %w(big brown fox hairy gorilla),
      Search.unstop(%w(the big brown fox and the hairy gorilla))
  end
  
  context "process" do
    test "simple" do
      assert_equal %w(aerospace defense systems),
        Search.process(["the aerospace defense", "systems of defense"])
    end

    test "complex" do
      assert_equal %w(earth has axial tilt 23.439 degrees),
        Search.process(["The earth has an axial tilt of 23.439 degrees."])
    end
  end
  
end

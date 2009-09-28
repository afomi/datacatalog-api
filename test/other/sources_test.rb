require File.expand_path(File.dirname(__FILE__) + '/../test_controller_helper')

class SourcesUnitTest < Test::Unit::TestCase
  
  context "merge_custom_fields" do
    before do
      @old = {
        "0" => {
          "label"       => "label 0",
          "description" => "description 0",
          "type"        => "string",
          "value"       => "foo"
        },
        "1" => {
          "label"       => "label 1",
          "description" => "description 1",
          "type"        => "string",
          "value"       => "bar"
        }
      }
    end
  
    test "modifying an attribute should work" do
      actual = ::DataCatalog::Sources.merge_custom_fields(@old,
        { "1" => { "value" => "quux" } })
      expected = @old.dup
      expected["1"]["value"] = "quux"
      assert_equal expected, actual
    end

    test "deleting a field should work" do
      actual = ::DataCatalog::Sources.merge_custom_fields(@old,
        { "1" => nil })
      expected = @old.dup
      expected["1"] = nil
      assert_equal expected, actual
    end
  end

  context "custom fields" do
    before do
      @custom = {
        "la_bel"      => "label 0",
        "description" => "description 0",
        "type"        => "string",
        "val_ue"      => "foo"
      }
    end

    test "#missing_custom_attrs" do
      missing = ::DataCatalog::Sources.missing_custom_attrs(@custom)
      assert_equal %w(label value), missing.sort
    end

    test "#invalid_custom_attrs" do
      invalid = ::DataCatalog::Sources.invalid_custom_attrs(@custom)
      assert_equal %w(la_bel val_ue), invalid.sort
    end
  end
  
end

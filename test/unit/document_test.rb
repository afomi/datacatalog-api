require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class DocumentUnitTest < ModelTestCase
  
  shared "valid document" do
    test "should be valid" do
      assert_equal true, @document.valid?
    end
  end

  shared "invalid document" do
    test "should not be valid" do
      assert_equal false, @document.valid?
    end
  end

  shared "document.text can't be empty" do
    test "text should not be empty" do
      @document.valid?
      assert_include :text, @document.errors.errors
      assert_include "must be empty", @document.errors.errors[:text]
    end
  end
  
  shared "document.user_id can't be empty" do
    test "should have empty error on user_id" do
      @document.valid?
      assert_include :user_id, @document.errors.errors
      assert_include "can't be empty", @document.errors.errors[:user_id]
    end
  end
  
  shared "document.user_id must be valid" do
    test "should have invalid error on user_id" do
      @document.valid?
      assert_include :user_id, @document.errors.errors
      assert_include "must be valid", @document.errors.errors[:user_id]
    end
  end

  shared "document.source_id can't be empty" do
    test "should have emptuy error on source_id" do
      @document.valid?
      assert_include :source_id, @document.errors.errors
      assert_include "can't be empty", @document.errors.errors[:source_id]
    end
  end

  shared "document.source_id must be valid" do
    test "should have invalid error on source_id" do
      @document.valid?
      assert_include :source_id, @document.errors.errors
      assert_include "must be valid", @document.errors.errors[:source_id]
    end
  end

  before do
    @user = create_user
    @source = create_source
    @valid_params = {
      :text      => "An explanation",
      :source_id => @source.id,
      :user_id   => @user.id,
    }
  end
  
  after do
    @source.destroy
    @user.destroy
  end
  
  context "Document.new : source" do
    context "invalid user_id" do
      before do
        @document = Document.new(@valid_params.merge(
          :user_id => get_fake_mongo_object_id
        ))
      end
  
      use "invalid document"
      use "document.user_id must be valid"
    end

    context "missing user_id" do
      before do
        @document = Document.new(@valid_params.merge(
          :user_id => ""
        ))
      end
      
      use "invalid document"
      use "document.user_id can't be empty"
    end

    context "invalid source_id" do
      before do
        @document = Document.new(@valid_params.merge(
          :source_id => get_fake_mongo_object_id
        ))
      end
  
      use "invalid document"
      use "document.source_id must be valid"
    end

    context "missing source_id" do
      before do
        @document = Document.new(@valid_params.merge(:source_id => ""))
      end
      
      use "invalid document"
      use "document.source_id can't be empty"
    end

    context "correct params" do
      before do
        @document = Document.new(@valid_params)
      end
      
      use "valid document"
    end
  end
  
  context "create_new_version!" do
    test "requires a saved Document" do
      document = Document.new(@valid_params)
      assert_raise DataCatalog::Error do
        document.create_new_version!
      end
    end
  
    context "saved Document" do
      before do
        @document = Document.create!(@valid_params)
        @copy = @document.create_new_version!
      end
      
      after do
        @copy.destroy
        @document.destroy
      end
      
      test "creates a new Document with unique id" do
        assert_equal Document, @copy.class
        assert @copy.id
        assert_not_equal @document.id, @copy.id
      end
      
      test "sets previous and next pointers" do
        assert_equal @document.id, @copy.next_id
        assert_equal @document.previous_id, @copy.id
      end
      
      test "creates an object with duplicate values" do
        @valid_params.each do |key, value|
          assert_equal value, @copy[key]
        end
      end
      
      test "updates current document but does not save it" do
        assert_equal true, @document.changed?
      end
    end
    
  end

end

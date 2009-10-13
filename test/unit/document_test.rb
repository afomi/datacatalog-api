# TODO: use get_fake_mongo_object_id instead of Mongo::ObjectID.new.to_s
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

  # - - - - - - - - - -
  
  context "Document.new : source" do
    before do
      @user = create_normal_user
      @source = create_source
      @valid_params = {
        :text      => "An explanation",
        :source_id => @source.id,
        :user_id   => @user.id,
      }
    end
    
    context "correct params" do
      before do
        @document = Document.new(@valid_params)
      end
      
      use "valid document"
    end

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
  end
  
end

require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class NoteUnitTest < ModelTestCase
  
  shared "valid note" do
    test "should be valid" do
      assert_equal true, @note.valid?
    end
  end

  shared "invalid note" do
    test "should not be valid" do
      assert_equal false, @note.valid?
    end
  end

  shared "note.text can't be empty" do
    test "text should not be empty" do
      @note.valid?
      assert_include :text, @note.errors.errors
      assert_include "must be empty", @note.errors.errors[:text]
    end
  end
  
  shared "note.user_id can't be empty" do
    test "should have empty error on user_id" do
      @note.valid?
      assert_include :user_id, @note.errors.errors
      assert_include "can't be empty", @note.errors.errors[:user_id]
    end
  end
  
  shared "note.user_id must be valid" do
    test "should have invalid error on user_id" do
      @note.valid?
      assert_include :user_id, @note.errors.errors
      assert_include "must be valid", @note.errors.errors[:user_id]
    end
  end

  shared "note.source_id can't be empty" do
    test "should have empty error on source_id" do
      @note.valid?
      assert_include :source_id, @note.errors.errors
      assert_include "can't be empty", @note.errors.errors[:source_id]
    end
  end

  shared "note.source_id must be valid" do
    test "should have invalid error on source_id" do
      @note.valid?
      assert_include :source_id, @note.errors.errors
      assert_include "must be valid", @note.errors.errors[:source_id]
    end
  end

  # - - - - - - - - - -
  
  context "Note : source" do
    before do
      @user = create_normal_user
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
    
    context "correct params" do
      before do
        @note = Note.new(@valid_params)
      end
      
      use "valid note"
    end

    context "invalid user_id" do
      before do
        @note = Note.new(@valid_params.merge(
          :user_id => get_fake_mongo_object_id
        ))
      end
  
      use "invalid note"
      use "note.user_id must be valid"
    end

    context "missing user_id" do
      before do
        @note = Note.new(@valid_params.merge(
          :user_id => nil
        ))
      end
      
      use "invalid note"
      use "note.user_id can't be empty"
    end

    context "invalid source_id" do
      before do
        @note = Note.new(@valid_params.merge(
          :source_id => get_fake_mongo_object_id
        ))
      end
  
      use "invalid note"
      use "note.source_id must be valid"
    end

    context "missing source_id" do
      before do
        @note = Note.new(@valid_params.merge(:source_id => nil))
      end
      
      use "invalid note"
      use "note.source_id can't be empty"
    end
  end
  
end

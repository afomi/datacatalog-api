require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class FavoriteUnitTest < ModelTestCase
  
  shared "valid favorite" do
    test "should be valid" do
      assert_equal true, @favorite.valid?
    end
  end

  shared "invalid favorite" do
    test "should not be valid" do
      assert_equal false, @favorite.valid?
    end
  end
  
  shared "favorite.user_id can't be empty" do
    test "should have empty error on user_id" do
      @favorite.valid?
      assert_include :user_id, @favorite.errors.errors
      assert_include "can't be empty", @favorite.errors.errors[:user_id]
    end
  end
  
  shared "favorite.user_id must be valid" do
    test "should have invalid error on user_id" do
      @favorite.valid?
      assert_include :user_id, @favorite.errors.errors
      assert_include "must be valid", @favorite.errors.errors[:user_id]
    end
  end

  shared "favorite.source_id can't be empty" do
    test "should have emptuy error on source_id" do
      @favorite.valid?
      assert_include :source_id, @favorite.errors.errors
      assert_include "can't be empty", @favorite.errors.errors[:source_id]
    end
  end

  shared "favorite.source_id must be valid" do
    test "should have invalid error on source_id" do
      @favorite.valid?
      assert_include :source_id, @favorite.errors.errors
      assert_include "must be valid", @favorite.errors.errors[:source_id]
    end
  end

  # - - - - - - - - - -
  
  context "Favorite.new : source" do
    before do
      @user = create_normal_user
      @source = create_source
      @valid_params = {
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
        @favorite = Favorite.new(@valid_params)
      end
      
      use "valid favorite"
    end

    context "invalid user_id" do
      before do
        @favorite = Favorite.new(@valid_params.merge(
          :user_id => get_fake_mongo_object_id
        ))
      end
  
      use "invalid favorite"
      use "favorite.user_id must be valid"
    end

    context "missing user_id" do
      before do
        @favorite = Favorite.new(@valid_params.merge(
          :user_id => ""
        ))
      end
      
      use "invalid favorite"
      use "favorite.user_id can't be empty"
    end

    context "invalid source_id" do
      before do
        @favorite = Favorite.new(@valid_params.merge(
          :source_id => get_fake_mongo_object_id
        ))
      end
  
      use "invalid favorite"
      use "favorite.source_id must be valid"
    end

    context "missing source_id" do
      before do
        @favorite = Favorite.new(@valid_params.merge(:source_id => ""))
      end
      
      use "invalid favorite"
      use "favorite.source_id can't be empty"
    end
  end
  
end

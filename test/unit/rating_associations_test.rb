require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class RatingAssociationsUnitTest < ModelTestCase
  
  context "Rating.create : source" do
    before do
      @user = create_normal_user
      @source = create_source(
        :title => "The Original Data Source",
        :url   => "http://data.gov/original"
      )
      @rating = Rating.create(
        :kind      => "source",
        :value     => 4,
        :text      => "An explanation",
        :user_id   => @user.id,
        :source_id => @source.id
      )
    end
    
    after do
      @rating.destroy
      @source.destroy
      @user.destroy
    end

    test "user should be valid" do
      assert @user.valid?
    end

    test "source should be valid" do
      assert @source.valid?
    end
    
    test "rating should be valid" do
      assert @rating.valid?
    end
    
    test "rating.user should be correct" do
      assert_equal @user, @rating.user
    end

    test "rating.source should be correct" do
      @source = Source.find_by_id!(@source.id)
      assert_equal @source, @rating.source
    end
    
    test "user.ratings should be correct" do
      ratings = @user.ratings.all
      assert_equal 1, ratings.length
      assert_include @rating, ratings
    end

    test "source.ratings should be correct" do
      ratings = @source.ratings.all
      assert_equal 1, ratings.length
      assert_include @rating, ratings
    end
  end
  
  context "Rating.create : comment" do
    before do
      @user = create_normal_user
      @comment = Comment.create(
        :text      => "Just a comment",
        :user_id   => @user.id,
        :source_id => Mongo::ObjectID.new.to_s
      )
      @rating = Rating.create(
        :kind       => "comment",
        :value      => 1,
        :user_id    => @user.id,
        :comment_id => @comment.id
      )
    end
  
    after do
      @rating.destroy
      @comment.destroy
      @user.destroy
    end
  
    test "user should be valid" do
      assert @user.valid?
    end
  
    test "comment should be valid" do
      assert @comment.valid?
    end
  
    test "rating should be valid" do
      assert @rating.valid?
    end
    
    test "rating.user should be correct" do
      assert_equal @user, @rating.user
    end
  
    test "rating.comment should be correct" do
      @comment = Comment.find_by_id(@comment.id)
      assert_equal @comment, @rating.comment
    end
    
    test "user.ratings should be correct" do
      ratings = @user.ratings.all
      assert_equal 1, ratings.length
      assert_include @rating, ratings
    end
  
    test "comment.ratings should be correct" do
      ratings = @comment.ratings.all
      assert_equal 1, ratings.length
      assert_include @rating, ratings
    end
  end
  
end

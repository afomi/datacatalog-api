require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class RatingAggregatesUnitTest < ModelTestCase

  context "Rating about a Source" do
    before do
      @user = create_normal_user
      @source = Source.create(
        :title => "Annual Electric Generator Report",
        :url   => "http://www.data.gov/details/858"
      )
    end
    
    test "ratings_total is 0" do
      assert_equal 0, @source.ratings_total
    end
  
    test "ratings_count is 0" do
      assert_equal 0, @source.ratings_count
    end

    context "new Rating" do
      before do
        @rating = Rating.create(
          :kind      => "source",
          :value     => 4,
          :user_id   => @user.id,
          :source_id => @source.id
        )
        raise "Must be valid" unless @rating.valid?
        @source = Source.find_by_id(@source.id)
      end
  
      test "updates ratings_total" do
        assert_equal 4, @source.ratings_total
      end
  
      test "increases ratings_count" do
        assert_equal 1, @source.ratings_count
      end
    
      context "updated Rating" do
        before do
          @rating.value = 2
          @rating.save!
          @source = Source.find_by_id(@source.id)
        end
      
        test "updates ratings_total" do
          assert_equal 2, @source.ratings_total
        end
    
        test "does not change ratings_count" do
          assert_equal 1, @source.ratings_count
        end
      end

      context "deleted Rating" do
        before do
          @rating.destroy
          @source = Source.find_by_id(@source.id)
        end
      
        test "updates ratings_total" do
          assert_equal 0, @source.ratings_total
        end
    
        test "does not change ratings_count" do
          assert_equal 0, @source.ratings_count
        end
      end
    end
  end
  
  context "Rating about a Comment" do
    before do
      @user = create_normal_user
      @source = Source.create(
        :title => "Annual Electric Generator Report",
        :url   => "http://www.data.gov/details/858"
      )
      @comment = Comment.create(
        :text      => "Original Comment",
        :user_id   => @user.id,
        :source_id => @source.id
      )
    end

    test "ratings_total is 0" do
      assert_equal 0, @comment.ratings_total
    end
  
    test "ratings_count is 0" do
      assert_equal 0, @comment.ratings_count
    end

    context "new Rating" do
      before do
        @rating = Rating.create(
          :kind       => "comment",
          :value      => 1,
          :user_id    => @user.id,
          :comment_id => @comment.id
        )
        raise "Must be valid" unless @rating.valid?
        @comment = Comment.find_by_id(@comment.id)
      end
  
      test "updates ratings_total" do
        assert_equal 1, @comment.ratings_total
      end
  
      test "increases ratings_count" do
        assert_equal 1, @comment.ratings_count
      end
    
      context "updated Rating" do
        before do
          @rating.value = 0
          @rating.save!
          @comment = Comment.find_by_id(@comment.id)
        end
      
        test "updates ratings_total" do
          assert_equal 0, @comment.ratings_total
        end
    
        test "does not change ratings_count" do
          assert_equal 1, @comment.ratings_count
        end
      end

      context "deleted Rating" do
        before do
          @rating.destroy
          @comment = Comment.find_by_id(@comment.id)
        end
      
        test "updates ratings_total" do
          assert_equal 0, @comment.ratings_total
        end
    
        test "does not change ratings_count" do
          assert_equal 0, @comment.ratings_count
        end
      end
    end

  end

end

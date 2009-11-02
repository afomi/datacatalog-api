require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class RatingAggregatesUnitTest < ModelTestCase

  context "Rating about a Source" do
    before do
      @user = create_normal_user
      @source = create_source(
        :title => "Annual Electric Generator Report",
        :url   => "http://www.data.gov/details/858"
      )
    end
    
    after do
      @source.destroy
      @user.destroy
    end
    
    test "ratings total is 0" do
      assert_equal 0, @source.rating_stats[:total]
    end
  
    test "ratings count is 0" do
      assert_equal 0, @source.rating_stats[:count]
    end

    test "ratings average is nil" do
      assert_equal nil, @source.rating_stats[:average]
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
        @source = Source.find_by_id!(@source.id)
      end

      test "updates ratings total" do
        assert_equal 4, @source.rating_stats[:total]
      end

      test "increases ratings count" do
        assert_equal 1, @source.rating_stats[:count]
      end

      test "updates ratings average" do
        assert_equal 4.0, @source.rating_stats[:average]
      end

      context "updated Rating" do
        before do
          @rating.value = 2
          @rating.save!
          @source = Source.find_by_id!(@source.id)
        end

        test "updates ratings total" do
          assert_equal 2, @source.rating_stats[:total]
        end

        test "does not change ratings count" do
          assert_equal 1, @source.rating_stats[:count]
        end

        test "updates ratings average" do
          assert_equal 2.0, @source.rating_stats[:average]
        end

      end

      context "deleted Rating" do
        before do
          @rating.destroy
          @source = Source.find_by_id!(@source.id)
        end
      
        test "updates ratings total" do
          assert_equal 0, @source.rating_stats[:total]
        end
    
        test "does not change ratings count" do
          assert_equal 0, @source.rating_stats[:count]
        end

        test "updates ratings average" do
          assert_equal nil, @source.rating_stats[:average]
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
      @comment = create_comment(
        :text      => "Original Comment",
        :user_id   => @user.id,
        :source_id => @source.id
      )
    end

    test "ratings total is 0" do
      assert_equal 0, @comment.rating_stats[:total]
    end
  
    test "ratings count is 0" do
      assert_equal 0, @comment.rating_stats[:count]
    end

    test "ratings average is nil" do
      assert_equal nil, @comment.rating_stats[:average]
    end

    context "new Rating" do
      before do
        @rating = create_comment_rating(
          :value      => 1,
          :user_id    => @user.id,
          :comment_id => @comment.id
        )
        @comment = Comment.find_by_id!(@comment.id)
      end
  
      test "updates ratings total" do
        assert_equal 1, @comment.rating_stats[:total]
      end
  
      test "increases ratings count" do
        assert_equal 1, @comment.rating_stats[:count]
      end

      test "updates ratings average" do
        assert_equal 1.0, @comment.rating_stats[:average]
      end
    
      context "updated Rating" do
        before do
          @rating.value = 0
          @rating.save!
          @comment = Comment.find_by_id!(@comment.id)
        end

        test "updates ratings total" do
          assert_equal 0, @comment.rating_stats[:total]
        end

        test "does not change ratings count" do
          assert_equal 1, @comment.rating_stats[:count]
        end

        test "updates ratings average" do
          assert_equal 0.0, @comment.rating_stats[:average]
        end
      end

      context "deleted Rating" do
        before do
          @rating.destroy
          @comment = Comment.find_by_id!(@comment.id)
        end
      
        test "updates ratings total" do
          assert_equal 0, @comment.rating_stats[:total]
        end
    
        test "does not change ratings count" do
          assert_equal 0, @comment.rating_stats[:count]
        end

        test "updates rating average" do
          assert_equal nil, @comment.rating_stats[:average]
        end
      end
    end

  end

end

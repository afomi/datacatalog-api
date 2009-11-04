require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class RatingsGetFilterTest < RequestTestCase

  def app; DataCatalog::Ratings end
  
  shared "successful GET of ratings where value is 2" do
    use "return 200 Ok"
    
    test "body should have 1 top level element" do
      assert_equal 1, parsed_response_body.length
    end
    
    docs_properties %w(kind comment_id source_id user_id text
      value previous_value id created_at updated_at) 

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "source rating 2", element['text']
        assert_equal 2, element["value"]
        assert_equal @user.id, element['user_id']
        assert_include "source_id", element
      end
    end
  end

  shared "successful GET of ratings with value greater than or equal to 4" do
    use "return 200 Ok"

    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    docs_properties %w(kind comment_id source_id user_id text
      value previous_value id created_at updated_at) 

    test "each element should be correct" do
      parsed_response_body.each do |element|
        value = element["value"]
        assert_equal true, value >= 4
        assert_equal "source rating #{value}", element['text']
        assert_equal @user.id, element['user_id']
      end
    end
  end

  shared "successful GET of ratings with value less than 4" do
    use "return 200 Ok"

    test "body should have 5 top level elements" do
      assert_equal 5, parsed_response_body.length
    end

    docs_properties %w(kind comment_id source_id user_id text
      value previous_value id created_at updated_at) 

    test "each element should be correct" do
      parsed_response_body.each do |element|
        value = element["value"]
        assert_equal true, value < 4
        assert_equal @user.id, element['user_id']
        case element["kind"]
        when "source"
          assert_equal "source rating #{value}", element['text']
          assert_include "source_id", element
        when "comment"
          assert_include "comment_id", element
        else flunk "incorrect kind of rating"
        end
      end
    end
  end

  context "7 ratings" do
    before do
      @user = create_user_with_primary_key

      @a_sources = 5.times.map do |i|
        create_source(
          :title => "Data Source A#{i}",
          :url   => "http://data.gov/sources/a/#{i}"
        )
      end
      @a_ratings = 5.times.map do |i|
        create_source_rating(
        :value     => i + 1,
        :text      => "source rating #{i + 1}",
        :user_id   => @user.id,
        :source_id => @a_sources[i].id
      )
      end

      @b_sources = 2.times.map do |i|
        create_source(
          :title => "Data Source B#{i}",
          :url   => "http://data.gov/sources/b/#{i}"
        )
      end
      @b_comments = 2.times.map do |i|
        create_comment(
          :text      => "comment #{i}",
          :user_id   => @user.id,
          :source_id => @b_sources[i].id
        )
      end
      @b_ratings = 2.times.map do |i|
        create_comment_rating(
          :value      => i,
          :user_id    => @user.id,
          :comment_id => @b_comments[i].id
        )
      end
    end

    after do
      @b_ratings.each { |x| x.destroy }
      @b_comments.each { |x| x.destroy }
      @b_sources.each { |x| x.destroy }

      @a_ratings.each { |x| x.destroy }
      @a_sources.each { |x| x.destroy }

      @user.destroy
    end

    context "owner API key : get / where value is 2" do
      before do
        get "/",
          :api_key => @user.primary_api_key,
          :filter  => "value = 2"
      end
    
      use "successful GET of ratings where value is 2"
    end
    
    context "owner API key : get / with value greater than or equal to 4" do
      before do
        get "/",
          :api_key => @user.primary_api_key,
          :filter  => "value >= 4"
      end
    
      use "successful GET of ratings with value greater than or equal to 4"
    end
    
    context "owner API key : get / with value greater than 3" do
      before do
        get "/",
          :api_key => @user.primary_api_key,
          :filter  => "value > 3"
      end
    
      use "successful GET of ratings with value greater than or equal to 4"
    end

    context "owner API key : get / with value less than 4" do
      before do
        get "/",
          :api_key => @user.primary_api_key,
          :filter  => "value < 4"
      end
    
      use "successful GET of ratings with value less than 4"
    end
    
    context "owner API key : get / with value less than or equal to 3" do
      before do
        get "/",
          :api_key => @user.primary_api_key,
          :filter  => "value <= 3"
      end
    
      use "successful GET of ratings with value less than 4"
    end
  end

end

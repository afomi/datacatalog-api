require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class RatingsGetAllTest < RequestTestCase

  def app; DataCatalog::Ratings end

  context "0 ratings" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
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

    context "basic API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return an empty list of members"
    end

    context "owner API key : get /" do
      before do
        get "/", :api_key => @user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 7 top level elements" do
        assert_equal 7, @members.length
      end

      members_properties %w(
        comment_id
        created_at
        id
        kind
        previous_value
        source_id
        text
        updated_at
        user_id
        value
      )

      test "correct values for each item" do
        source_ratings = []
        comment_ratings = []
        @members.each do |rating|
          case rating["kind"]
          when "source"
            source_ratings << rating
          when "comment"
            comment_ratings << rating
          else
            flunk "incorrect kind of rating"
          end
        end
        source_ratings.each do |x|
          assert_equal "source rating #{x['value']}", x['text']
        end
        assert_equal [1, 2, 3, 4, 5],
          source_ratings.map { |x| x["value"] }.sort
        assert_equal [0, 1],
          comment_ratings.map { |x| x["value"] }.sort
      end
    end
  end

end

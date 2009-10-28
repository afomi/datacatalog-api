require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    @source = Source.create(
      :title => "The Original Data Source",
      :url   => "http://data.gov/original"
    )
    @id = source.id
    @fake_id = get_fake_mongo_object_id
  end

  shared "attempted GET source with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
  
  after do
    @source.destroy
  end

  shared "successful GET source with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"

    test "body should have correct text" do
      assert_equal "http://data.gov/original", parsed_response_body["url"]
    end

    test "body should have correct attributes" do
      assert_include "title"              , parsed_response_body
      assert_include "slug"               , parsed_response_body
      assert_include "description"        , parsed_response_body
      assert_include "type"               , parsed_response_body
      assert_include "license"            , parsed_response_body
      assert_include "catalog_name"       , parsed_response_body
      assert_include "url"                , parsed_response_body
      assert_include "documentation_url"  , parsed_response_body
      assert_include "license_url"        , parsed_response_body
      assert_include "catalog_url"        , parsed_response_body      
      assert_include "released"           , parsed_response_body
      assert_include "period_start"       , parsed_response_body
      assert_include "period_end"         , parsed_response_body
      assert_include "rating_stats"       , parsed_response_body
      rating_stats = parsed_response_body["rating_stats"]
      assert_include "count",        rating_stats
      assert_include "average",      rating_stats
      assert_include "total",        rating_stats
    end
  end

  context "get /:id" do
    context "anonymous" do
      before do
        get "/#{@id}"
      end
      
      use "return 401 because the API key is missing"
    end
  
    context "incorrect API key" do
      before do
        get "/#{@id}", :api_key => "does_not_exist_in_database"
      end
    
      use "return 401 because the API key is invalid"
    end
  end

  %w(normal curator admin).each do |role|
    context "#{role} API key : get /:fake_id" do
      before do
        get "/#{@fake_id}", :api_key => primary_api_key_for(role)
      end
      
      use "attempted GET source with :fake_id"
    end
  
    context "#{role} API key : get /:id" do
      before do
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET source with :id"
    end

    context "#{role} API key : 3 categorizations : get /:id" do
      before do
        @categories = %w(Energy Finance Poverty).map do |name|
          create_category(:name => name)
        end
        @categorizations = @categories.map do |category|
          create_categorization(
            :category_id => category.id,
            :source_id   => @source.id
          )
        end
        get "/#{@source.id}", :api_key => primary_api_key_for(role)
      end
      
      after do
        @categorizations.each { |x| x.destroy }
        @categories.each { |x| x.destroy }
      end
      
      use "successful GET source with :id"
      
      test "body should have correct categories" do
        actual = parsed_response_body["categories"]
        @categories.each do |category|
          expected = {
            "href" => "/categories/#{category.id}",
            "name" => category.name,
          }
          assert_include expected, actual
        end
      end
    end

    context "#{role} API key : 2 comments : get /:id" do
      before do
        @comments = [
          create_comment({
            :text      => "Comment 1",
            :source_id => @source.id,
          }),
          create_comment({
            :text      => "Comment 2",
            :source_id => @source.id,
          })
        ]
        @ratings = []
        @comments.each do |comment|
          [0, 1].each do |value|
            @ratings << create_comment_rating({
              :value      => value,
              :comment_id => comment.id
            })
          end
        end
        get "/#{@source.id}", :api_key => primary_api_key_for(role)
      end
      
      after do
        @ratings.each { |x| x.destroy }
        @comments.each { |x| x.destroy }
      end
      
      use "successful GET source with :id"
      
      test "body should have correct comments" do
        actual = parsed_response_body["comments"]
        @comments.each do |comment|
          expected = {
            "href" => "/comments/#{comment.id}",
            "text" => comment.text,
            "rating_stats" => {
              "count"   => 2,
              "total"   => 1,
              "average" => 0.5
            },
            "user" => {
              "name" => "Normal User",
              "href" => "/users/#{@normal_user.id}"
            }
          }
          assert_include expected, actual
        end
      end
    end
      
    context "#{role} API key : 2 documents : get /:id" do
      before do
        @documents = [
          create_document({
            :text      => "Document 1",
            :source_id => @source.id,
          }),
          create_document({
            :text      => "Document 2",
            :source_id => @source.id,
          })
        ]
        get "/#{@source.id}", :api_key => primary_api_key_for(role)
      end
      
      after do
        @documents.each { |x| x.destroy }
      end
      
      use "successful GET source with :id"
      
      test "body should have correct documents" do
        actual = parsed_response_body["documents"]
        @documents.each do |document|
          expected = {
            "href" => "/documents/#{document.id}",
            "text" => document.text,
            "user" => {
              "name" => "Normal User",
              "href" => "/users/#{@normal_user.id}"
            }
          }
          assert_include expected, actual
        end
      end
    end
      
    context "#{role} API key : 2 notes : get /:id" do
      before do
        @notes = [
          create_note({
            :text      => "Note 1",
            :source_id => @source.id,
          }),
          create_note({
            :text      => "Note 2",
            :source_id => @source.id,
          })
        ]
        get "/#{@source.id}", :api_key => primary_api_key_for(role)
      end
      
      after do
        @notes.each { |x| x.destroy }
      end
      
      use "successful GET source with :id"
      
      test "body should have correct notes" do
        actual = parsed_response_body["notes"]
        @notes.each do |note|
          expected = {
            "href" => "/notes/#{note.id}",
            "text" => note.text,
            "user" => {
              "name" => "Normal User",
              "href" => "/users/#{@normal_user.id}"
            }
          }
          assert_include expected, actual
        end
      end
    end

    context "#{role} API key : 2 ratings : get /:id" do
      before do
        @source_ratings = [
          create_source_rating(
            :value     => 1,
            :source_id => @source.id
          ),
          create_source_rating(
            :value     => 5,
            :source_id => @source.id
          )
        ]
        # Just to make sure comment ratings don't get included
        # in source.ratings.
        @comment = create_comment(
          :source_id => @source.id
        )
        @comment_ratings = [
          create_comment_rating(
            :value      => 0,
            :comment_id => @comment.id
          ),
          create_comment_rating(
            :value      => 1,
            :comment_id => @comment.id
          )
        ]
        get "/#{@source.id}", :api_key => primary_api_key_for(role)
      end
      
      after do
        @comment_ratings.each { |x| x.destroy }
        @comment.destroy
        @source_ratings.each { |x| x.destroy }
      end
      
      use "successful GET source with :id"
      
      test "body should have correct ratings total" do
        assert_equal 6, parsed_response_body["rating_stats"]["total"]
      end
      
      test "body should have correct ratings count" do
        assert_equal 2, parsed_response_body["rating_stats"]["count"]
      end
      
      test "body should have correct ratings average" do
        assert_equal 3.0, parsed_response_body["rating_stats"]["average"]
      end
      
      test "body should have correct ratings" do
        actual = parsed_response_body["ratings"]
        assert_equal 2, actual.length
        @source_ratings.each do |rating|
          expected = {
            "href"  => "/ratings/#{rating.id}",
            "text"  => rating.text,
            "value" => rating.value,
            "user"  => {
              "name" => "Normal User",
              "href" => "/users/#{@normal_user.id}"
            }
          }
          assert_include expected, actual
        end
      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourcesGetOneTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    @source = create_source(
      :title => "The Original Data Source",
      :url   => "http://data.gov/original"
    )
  end
  
  after do
    @source.destroy
  end

  shared "successful GET source with :id" do
    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "http://data.gov/original", parsed_response_body["url"]
    end
    
    doc_properties %w(
      catalog_name
      catalog_url
      categories
      comments
      created_at
      custom
      description
      documentation_url
      documents
      frequency
      id
      license
      license_url
      notes
      organization
      organization_id
      period_end
      period_start
      ratings
      rating_stats
      raw
      released
      slug
      source_type
      title
      updated_at
      updates_per_year
      url
    )

    test "body should have rating stats" do
      rating_stats = parsed_response_body["rating_stats"]
      assert_include "count",        rating_stats
      assert_include "average",      rating_stats
      assert_include "total",        rating_stats
    end

    test "body should have organization field" do
      assert_equal nil, parsed_response_body["organization"]
    end
  end

  %w(normal).each do |role|
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
            "href"   => "/comments/#{comment.id}",
            "text"   => comment.text,
            "parent" => nil,
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

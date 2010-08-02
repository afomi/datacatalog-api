require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')
require 'timecop'

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
      downloads
      favorite_count
      frequency
      id
      license
      license_url
      notes
      organization
      organization_id
      jurisdiction
      jurisdiction_id
      period_end
      period_start
      ratings
      rating_stats
      raw
      versions
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

    context "#{role} API key : 1 jurisdiction : get /:id" do
      before do
        @jurisdiction = create_organization(
          :name      => "US Federal Government",
          :org_type  => "governmental",
          :top_level => true 
        )
        @organization = create_organization(
          :name      => "Department of Commerce",
          :org_type  => "governmental",
          :parent_id => @jurisdiction.id
        )

        @source.organization = @organization
        @source.save!
        get "/#{@source.id}", :api_key => primary_api_key_for(role)
      end

      after do
        @organization.destroy
        @jurisdiction.destroy
      end

      use "successful GET source with :id"

      test "body should have correct organization" do
        actual = parsed_response_body["organization"]
        expected = {
          "name" => "Department of Commerce",
          "href" => "/organizations/#{@organization.id}",
          "slug" => "department-of-commerce"
        }
        assert_equal expected, actual
      end

      test "body should have correct organization_id" do
        assert_equal @organization.id.to_s, parsed_response_body["organization_id"]
      end

      test "body should have correct jurisdiction_id" do
        assert_equal @jurisdiction.id.to_s, parsed_response_body["jurisdiction_id"] # fails
      end

      test "body should have correct jurisdiction" do
        actual = parsed_response_body["jurisdiction"]
        expected = {
          "slug" => "us-federal-government",
          "name" => "US Federal Government",
          "href" => "/organizations/#{@jurisdiction.id}"
        }
        assert_equal expected, actual
      end

    end

    context "#{role} API key : 2 comments : get /:id" do
      before do
        Timecop.freeze
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
        Timecop.return
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
            "created_at" => Time.now.gmtime.strftime("%Y/%m/%d %H:%M:%S +0000"),
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

      context "#{role} API key : 2 downloads : get /:id" do
        before do
          @downloads = [
            create_download({
              :format    => "csv",
              :url       => "http://dl.gov/data/6.csv",
              :source_id => @source.id,
            }),
            create_download({
              :format    => "xml",
              :url       => "http://dl.gov/data/6.xml",
              :source_id => @source.id,
            })
          ]
          get "/#{@source.id}", :api_key => primary_api_key_for(role)
        end

        after do
          @downloads.each { |x| x.destroy }
        end

        use "successful GET source with :id"

        test "body should have correct downloads" do
          actual = parsed_response_body["downloads"]
          @downloads.each do |download|
            expected = {
              "href"    => "/downloads/#{download.id}",
              "url"     => download.url,
              "format"  => download.format,
              "size"    => download.size['number'],
              "preview" => download.preview,
            }
            assert_include expected, actual
          end
        end
      end

    end

  end

end

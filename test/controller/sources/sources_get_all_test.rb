require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  shared "successful GET of 0 sources" do
    use "return 200 Ok"
    use "return an empty list response body"
  end
  
  shared "successful GET of 3 sources" do
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "body should have correct text" do
      actual = (0 ... 3).map { |n| parsed_response_body[n]["url"] }
      3.times { |n| assert_include "http://data.gov/sources/#{n}", actual }
    end

    test "each element should have correct attributes" do
      parsed_response_body.each do |element|
        assert_include "title"              , element
        assert_include "slug"               , element
        assert_include "description"        , element
        assert_include "source_type"        , element
        assert_include "license"            , element
        assert_include "catalog_name"       , element
        assert_include "url"                , element
        assert_include "documentation_url"  , element
        assert_include "license_url"        , element
        assert_include "catalog_url"        , element
        assert_include "released"           , element
        assert_include "period_start"       , element
        assert_include "period_end"         , element
        assert_include "rating_stats"       , element
        rating_stats = element["rating_stats"]
        assert_include "count",        rating_stats
        assert_include "average",      rating_stats
        assert_include "total",        rating_stats

        assert_include "created_at"    , element
        assert_include "updated_at"    , element
        assert_include "id"            , element
        assert_not_include "_id", element
      end
    end
  end

  context "0 sources" do
    %w(normal).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
        end

        use "successful GET of 0 sources"
      end
    end
  end

  context "3 sources" do
    before do
      @sources = 3.times.map do |n|
        create_source(
          :title => "Source #{n}", 
          :url   => "http://data.gov/sources/#{n}",
          :slug  => "source-#{n}",
          :source_type  => "dataset"
        )
      end
    end
    
    after do
      @sources.each { |s| s.destroy }
    end

    %w(normal).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
        end

        use "successful GET of 3 sources"
      end
    end
  end

end

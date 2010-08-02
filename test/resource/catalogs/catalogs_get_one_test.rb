require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CatalogsGetOneTest < RequestTestCase

  def app; DataCatalog::Catalogs end

  before do
    @catalog = create_catalog
    @source = create_source(:catalog_id => @catalog.id)
  end

  after do
    @source.destroy
    @catalog.destroy
  end

  %w(normal).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@catalog.id}", :api_key => primary_api_key_for(role)
      end

      use "return 200 Ok"

      test "body should have correct url" do
        assert_equal "http://bigdata.gov", parsed_response_body["url"]
      end

      doc_properties %w(
        created_at
        id
        sources
        title
        updated_at
        url
      )

      test "body should have sources" do
        sources = parsed_response_body["sources"]
        assert_equal 1, sources.size
      end

      test "body should have sources in correct form" do
        actual = parsed_response_body["sources"]
        expected = {
          "href"  => "/sources/#{@source.id}",
          "title" => @source.title,
          "url"   => @source.url,
        }
        assert_include expected, actual
      end
    end
  end
end

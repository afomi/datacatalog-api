require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CatalogsGetAllTest < RequestTestCase

  def app; DataCatalog::Catalogs end

  shared "successful GET of 0 catalogs" do
    use "return 200 Ok"
    use "return an empty list of members"
  end

  shared "successful GET of 3 catalogs" do
    test "body should have 3 top level elements" do
      assert_equal 3, @members.length
    end

    test "body should have correct urls" do
      actual = @members.map { |m| m["url"] }
      3.times.each do |i|
        assert_include "http://data.gov/catalog/#{i}", actual
      end
    end

    members_properties %w(
      created_at
      id
      score_stats
      sources
      title
      updated_at
      url
    )
  end

  context "0 catalogs" do
    %w(normal).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
          @members = parsed_response_body['members']
        end

        use "successful GET of 0 catalogs"
      end
    end
  end

  context "3 catalogs" do
    before do
      @catalogs = 3.times.map do |x|
        create_catalog(
          :title => "Catalog #{x}",
          :url   => "http://data.gov/catalog/#{x}"
        )
      end
    end

    after do
      @catalogs.each { |c| c.destroy }
    end

    %w(normal).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
          @members = parsed_response_body['members']
        end

        use "successful GET of 3 catalogs"
      end
    end
  end

end

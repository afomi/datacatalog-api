require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ImportersGetOneTest < RequestTestCase

  def app; DataCatalog::Importers end

  before do
    @importer = create_importer({
      :name => "hawaii.gov"
    })
  end

  after do
    @importer.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@importer.id}", :api_key => @curator_user.primary_api_key
    end

    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "hawaii.gov", parsed_response_body["name"]
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ImportsGetOneTest < RequestTestCase

  def app; DataCatalog::Imports end

  before do
    @importer = create_importer({
      :name => "hawaii.gov"
    })
    @import = create_import({
      :importer_id => @importer.id
    })
  end

  after do
    @import.destroy
    @importer.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@import.id}", :api_key => @curator_user.primary_api_key
    end

    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal @importer.id.to_s, parsed_response_body["importer_id"]
    end
  end

end

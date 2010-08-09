require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CatalogsPutTest < RequestTestCase

  def app; DataCatalog::Catalogs end

  before do
    @catalog = create_catalog(:title => "Original Catalog")
    @catalog_count = Catalog.count
  end

  after do
    @catalog.destroy
  end

  shared "unchanged catalog title in database" do
    test "title should be unchanged in database" do
      assert_equal "Original Catalog", @catalog.title
    end
  end

  context "basic API key : put /:id" do
    before do
      put "/#{@catalog.id}",
        :api_key => @normal_user.primary_api_key,
        :title   => "New Catalog"
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged catalog title in database"
  end

  context "normal API key : put /:id" do
    before do
      put "/#{@catalog.id}",
        :api_key => @normal_user.primary_api_key,
        :title   => "New Catalog"
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged catalog title in database"
  end

  context "curator API key : put /:id" do
    before do
      put "/#{@catalog.id}",
        :api_key => @curator_user.primary_api_key,
        :title   => "New Catalog"
    end

    use "return 200 Ok"
    use "unchanged catalog count"

    test "title should be updated in database" do
      catalog = Catalog.find_by_id!(@catalog.id)
      assert_equal "New Catalog", catalog.title
    end
  end
end

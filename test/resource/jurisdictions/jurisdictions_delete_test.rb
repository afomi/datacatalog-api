require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class JurisdictionsDeleteTest < RequestTestCase

  def app; DataCatalog::Jurisdictions end

  before do
    @jurisdiction = create_jurisdiction(
      :name => "Original Jurisdiction"
    )
    @jurisdiction_count = Jurisdiction.count
  end

  after do
    @jurisdiction.destroy
  end
  
  context "basic API key : delete /:id" do
    before do
      delete "/#{@jurisdiction.id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged jurisdiction count"
  end

  context "curator API key : delete /:id" do
    before do
      delete "/#{@jurisdiction.id}", :api_key => @curator_user.primary_api_key
    end
    
    use "return 204 No Content"
    use "decremented jurisdiction count"

    test "jurisdiction should be deleted in database" do
      assert_equal nil, Jurisdiction.find_by_id(@id)
    end
  end

end

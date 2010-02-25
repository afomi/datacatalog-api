require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class JurisdictionsPutTest < RequestTestCase

  def app; DataCatalog::Jurisdictions end

  before do
    @user = create_user_with_primary_key
    @jurisdiction = create_jurisdiction(
      :name     => "Original Jurisdiction",
      :user_id  => @user.id
    )
    @jurisdiction_count = Jurisdiction.count
  end
  
  after do
    @jurisdiction.destroy
    @user.destroy
  end

  shared "unchanged jurisdiction name in database" do
    test "name should be unchanged in database" do
      assert_equal "Original Jurisdiction", @jurisdiction.name
    end
  end
  
  context "basic API key : put /:id" do
    before do
      put "/#{@jurisdiction.id}",
        :api_key => @normal_user.primary_api_key,
        :name    => "New Jurisdiction"
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged jurisdiction name in database"
  end

  context "owner API key : put /:id" do
    before do
      put "/#{@jurisdiction.id}",
        :api_key => @normal_user.primary_api_key,
        :name    => "New Jurisdiction"
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged jurisdiction name in database"
  end
  
  context "curator API key : put /:id" do
    before do
      put "/#{@jurisdiction.id}",
        :api_key => @curator_user.primary_api_key,
        :name    => "New Jurisdiction"
    end
    
    use "return 200 Ok"
    use "unchanged jurisdiction count"
  
    test "name should be updated in database" do
      jurisdiction = Jurisdiction.find_by_id!(@jurisdiction.id)
      assert_equal "New Jurisdiction", jurisdiction.name
    end
  end

end

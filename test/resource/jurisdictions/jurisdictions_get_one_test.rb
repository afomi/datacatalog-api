require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class JurisdictionsGetOneTest < RequestTestCase

  def app; DataCatalog::Jurisdictions end

  before do
    @user = create_user_with_primary_key
    @jurisdiction = create_jurisdiction(
      :name      => "Jurisdiction A",
      :user_id   => @user.id
    )
  end
  
  after do
    @jurisdiction.destroy
    @user.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@jurisdiction.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct values" do
      assert_equal "Jurisdiction A", parsed_response_body["name"]
      assert_equal @user.id.to_s, parsed_response_body["user_id"]
    end
    
  end

end

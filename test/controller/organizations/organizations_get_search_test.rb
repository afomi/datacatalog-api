require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Organizations end
  
  context "6 organizations" do
    before do
      @user = create_user_with_primary_key
      @organizations = 6.times.map do |i|
        create_organization(
          :name    => "organization #{(i % 3) + 1}",
          :user_id => @user.id
        )
      end
    end
    
    after do
      @organizations.each { |x| x.destroy }
      @user.destroy
    end

    context "normal API key : get / where name is 'organization 3'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => 'name="organization 3"'
      end
      
      use "return 200 Ok"
    
      test "body should have correct elements" do
        assert_equal 2, parsed_response_body.length
        parsed_response_body.each do |resource|
          assert_equal "organization 3", resource["name"]
          assert_equal @user.id, resource["user_id"]
        end
      end
    end
  end

end

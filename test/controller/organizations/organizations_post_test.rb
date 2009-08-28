require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsPostControllerTest < RequestTestCase

  before do
    @organization_count = Organization.count
  end

  # - - - - - - - - - -

  context "anonymous : post /organizations" do
    before do
      post '/organizations'
    end
    
    use "return 401 because the API key is missing"
    use "unchanged organization count"
  end
  
  context "incorrect API key : post /organizations" do
    before do
      post '/organizations', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged organization count"
  end

  # - - - - - - - - - -
  
  context "normal API key : post /organizations : protected param 'updated_at'" do
    before do
      post '/organizations', {
        :api_key    => @normal_user.primary_api_key,
        :text       => "Organization A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "return errors hash saying updated_at is invalid"
  end

  context "curator API key : post /organizations : protected param 'updated_at'" do
    before do
      post '/organizations', {
        :api_key    => @curator_user.primary_api_key,
        :text       => "Organization A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "return errors hash saying updated_at is invalid"
  end

  context "admin API key : post /organizations : protected param 'updated_at'" do
    before do
      post '/organizations', {
        :api_key    => @admin_user.primary_api_key,
        :text       => "Organization A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "return errors hash saying updated_at is invalid"
  end

  # - - - - - - - - - -

  context "normal API key : post /organizations : extra param 'junk'" do
    before do
      post '/organizations', {
        :api_key => @normal_user.primary_api_key,
        :text    => "Organization A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "return errors hash saying junk is invalid"
  end

  context "curator API key : post /organizations : extra param 'junk'" do
    before do
      post '/organizations', {
        :api_key => @curator_user.primary_api_key,
        :text    => "Organization A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "return errors hash saying junk is invalid"
  end

  context "admin API key : post /organizations : extra param 'junk'" do
    before do
      post '/organizations', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Organization A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "return errors hash saying junk is invalid"
  end
  
  # - - - - - - - - - -
  
  shared "shared tests for successful update of organizations" do
    test "location header should point to new reorganization" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/organizations/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct text" do
      assert_equal "Organization A", parsed_response_body["text"]
    end

    test "text should be correct in database" do
      organization = Organization.find_by_id(parsed_response_body["id"])
      assert_equal "Organization A", organization.text
    end
  end
  
  shared "needs_curation should be false" do
    test "body should have needs_curation set to false" do
      assert_equal false, parsed_response_body["needs_curation"]
    end

    test "needs_curation should be false in database" do
      organization = Organization.find_by_id(parsed_response_body["id"])
      assert_equal false, organization.needs_curation
    end
  end

  shared "needs_curation should be true" do
    test "body should have needs_curation set to true" do
      assert_equal true, parsed_response_body["needs_curation"]
    end

    test "needs_curation should be true in database" do
      organization = Organization.find_by_id(parsed_response_body["id"])
      assert_equal true, organization.needs_curation
    end
  end

  # - - - - - - - - - -

  context "normal API key : post /organizations : correct params" do
    before do
      post '/organizations', {
        :api_key => @normal_user.primary_api_key,
        :text    => "Organization A",
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented organization count"
    use "shared tests for successful update of organizations"
    use "needs_curation should be true"

    test "body should have user_id matching the normal user" do
      assert_equal @normal_user.id, parsed_response_body["user_id"]
    end
    
    test "user_id should match normal user in database" do
      organization = Organization.find_by_id(parsed_response_body["id"])
      assert_equal @normal_user.id, organization.user_id
    end
  end

  context "curator API key : post /organizations : correct params" do
    before do
      post '/organizations', {
        :api_key => @curator_user.primary_api_key,
        :text    => "Organization A",
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented organization count"
    use "shared tests for successful update of organizations"
    use "needs_curation should be false"

    test "body should have user_id matching the curator user" do
      assert_equal @curator_user.id, parsed_response_body["user_id"]
    end
    
    test "user_id should match curator user in database" do
      organization = Organization.find_by_id(parsed_response_body["id"])
      assert_equal @curator_user.id, organization.user_id
    end
  end
  
  context "admin API key : post /organizations : correct params" do
    before do
      post '/organizations', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Organization A",
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented organization count"
    use "shared tests for successful update of organizations"
    use "needs_curation should be false"

    test "body should have user_id matching the admin user" do
      assert_equal @admin_user.id, parsed_response_body["user_id"]
    end
    
    test "user_id should match admin user in database" do
      organization = Organization.find_by_id(parsed_response_body["id"])
      assert_equal @admin_user.id, organization.user_id
    end
  end

end

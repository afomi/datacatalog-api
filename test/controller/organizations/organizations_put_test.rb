require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsPutControllerTest < RequestTestCase

  before do
    @organization = Organization.create({
      :text => "Original Organization"
    })
    @id = @organization.id
    @fake_id = get_fake_mongo_object_id
    @organization_count = Organization.count
  end

  # - - - - - - - - - -
  
  shared "unchanged organization text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Organization", @organization.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /organizations" do
    before do
      put "/organizations/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged organization count"
  end

  context "incorrect API key : put /organizations" do
    before do
      put "/organizations/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged organization count"
  end
  
  context "normal API key : put /organizations" do
    before do
      put "/organizations/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged organization count"
  end

  # - - - - - - - - - -

  context "admin API key : put /organizations : attempt to create : protected param 'create_at'" do
    before do
      put "/organizations/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Organization",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
    use "unchanged organization text in database"
  end

  context "admin API key : put /organizations : attempt to create : extra param 'junk'" do
    before do
      put "/organizations/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
    use "unchanged organization text in database"
  end
  
  context "admin API key : put /organizations : attempt to create : correct params" do
    before do
      put "/organizations/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
    use "unchanged organization text in database"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : put /organizations : update : protected param 'updated_at'" do
    before do
      put "/organizations/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Organization",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "unchanged organization text in database"
    use "return errors hash saying updated_at is invalid"
  end
  
  context "admin API key : put /organizations : update : extra param 'junk'" do
    before do
      put "/organizations/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "unchanged organization text in database"
    use "return errors hash saying junk is invalid"
  end

  # - - - - - - - - - -
  
  context "admin API key : put /organizations : update : correct params" do
    before do
      put "/organizations/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization"
      }
    end
  
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged organization count"
  
    test "text should be updated in database" do
      organization = Organization.find_by_id(@id)
      assert_equal "New Organization", organization.text
    end
  end

end

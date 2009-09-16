require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsPutControllerTest < RequestTestCase

  def app; DataCatalog::Organizations end

  before :all do
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

  shared "attempted PUT organization with :fake_id with protected param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
    use "unchanged organization text in database"
  end

  shared "attempted PUT organization with :fake_id with invalid param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
    use "unchanged organization text in database"
  end

  shared "attempted PUT organization with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged organization count"
    use "unchanged organization text in database"
  end

  shared "attempted PUT organization with :id with protected param" do
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "unchanged organization text in database"
    use "return errors hash saying updated_at is invalid"
  end

  shared "attempted PUT organization with :id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged organization count"
    use "unchanged organization text in database"
    use "return errors hash saying junk is invalid"
  end

  shared "attempted PUT organization with :id without params" do
    use "return 400 Bad Request"
    use "unchanged organization count"
    
    test "body should say 'no_params_to_save'" do
      assert_include "no_params_to_save", parsed_response_body["errors"]
    end
  
    test "return help_text saying params are needed" do
      assert_include "cannot save without parameters", parsed_response_body["help_text"]
    end
  end
  
  shared "successful PUT organization with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged organization count"

    test "text should be updated in database" do
      organization = Organization.find_by_id(@id)
      assert_equal "New Organization", organization.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /" do
    before do
      put "/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged organization count"
  end

  context "incorrect API key : put /" do
    before do
      put "/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged organization count"
  end

  context "normal API key : put /" do
    before do
      put "/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged organization count"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Organization",
        :created_at => Time.now.to_json
      }
    end
    
    use "attempted PUT organization with :fake_id with protected param"
  end

  context "admin API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Organization",
        :created_at => Time.now.to_json
      }
    end
  
    use "attempted PUT organization with :fake_id with protected param"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Organization",
        :junk    => "This is an extra param (junk)"
      }
    end
    
    use "attempted PUT organization with :fake_id with invalid param"
  end
  
  context "admin API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT organization with :fake_id with invalid param"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Organization"
      }
    end
    
    use "attempted PUT organization with :fake_id with correct params"
  end
    
  context "admin API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization"
      }
    end
  
    use "attempted PUT organization with :fake_id with correct params"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Organization",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT organization with :id with protected param"
  end

  context "admin API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Organization",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT organization with :id with protected param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Organization",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT organization with :id with invalid param"
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT organization with :id with invalid param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key
      }
    end

    use "attempted PUT organization with :id without params"
  end

  context "admin API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key
      }
    end

    use "attempted PUT organization with :id without params"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Organization"
      }
    end
    
    use "successful PUT organization with :id"
  end
  
  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Organization"
      }
    end
    
    use "successful PUT organization with :id"
  end

end

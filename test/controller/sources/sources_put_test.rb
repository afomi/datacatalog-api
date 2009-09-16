require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesPutControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before :all do
    @source = Source.create({
      :url => "http://data.gov/original"
    })
    @id = @source.id
    @fake_id = get_fake_mongo_object_id
    @source_count = Source.count
  end

  # - - - - - - - - - -

  shared "unchanged source text in database" do
    test "url should be unchanged in database" do
      assert_equal "http://data.gov/original", @source.url
    end
  end

  shared "attempted PUT source with :fake_id with protected param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
    use "unchanged source text in database"
  end

  shared "attempted PUT source with :fake_id with invalid param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
    use "unchanged source text in database"
  end

  shared "attempted PUT source with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
    use "unchanged source text in database"
  end

  shared "attempted PUT source with :id with protected param" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged source text in database"
    use "return errors hash saying updated_at is invalid"
  end

  shared "attempted PUT source with :id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged source text in database"
    use "return errors hash saying junk is invalid"
  end
  
  shared "attempted PUT source with :id with invalid url" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "return errors hash saying url scheme is incorrect"
  end
  
  shared "attempted PUT source with :id without params" do
    use "return 400 Bad Request"
    use "unchanged source count"
    
    test "body should say 'no_params_to_save'" do
      assert_include "no_params_to_save", parsed_response_body["errors"]
    end

    test "return help_text saying params are needed" do
      assert_include "cannot save without parameters", parsed_response_body["help_text"]
    end
  end

  shared "successful PUT source with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged source count"

    test "url should be updated in database" do
      source = Source.find_by_id(@id)
      assert_equal "http://data.gov/updated", source.url
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /" do
    before do
      put "/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged source count"
  end

  context "incorrect API key : put /" do
    before do
      put "/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged source count"
  end
  
  context "normal API key : put /" do
    before do
      put "/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @curator_user.primary_api_key,
        :url        => "http://data.gov/updated",
        :created_at => Time.now.to_json
      }
    end
    
    use "attempted PUT source with :fake_id with protected param"
  end
  
  context "admin API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :url        => "http://data.gov/updated",
        :created_at => Time.now.to_json
      }
    end
  
    use "attempted PUT source with :fake_id with protected param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :url     => "http://data.gov/updated",
        :junk    => "This is an extra param (junk)"
      }
    end
    
    use "attempted PUT source with :fake_id with invalid param"
  end
  
  context "admin API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/updated",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT source with :fake_id with invalid param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :url     => "http://data.gov/updated"
      }
    end
    
    use "attempted PUT source with :fake_id with correct params"
  end
    
  context "admin API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/updated"
      }
    end
  
    use "attempted PUT source with :fake_id with correct params"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @curator_user.primary_api_key,
        :url        => "http://data.gov/updated",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT source with :id with protected param"
  end
  
  context "admin API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :url        => "http://data.gov/updated",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT source with :id with protected param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :url     => "http://data.gov/updated",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT source with :id with invalid param"
  end
  
  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/updated",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT source with :id with invalid param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with invalid url" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :url     => "https://secret.com/13"
      }
    end
    
    use "attempted PUT source with :id with invalid url"
  end

  context "admin API key : put /:id with invalid url" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "https://secret.com/13"
      }
    end
  
    use "attempted PUT source with :id with invalid url"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id without url" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key
      }
    end

    use "attempted PUT source with :id without params"
  end
  
  context "admin API key : put /:id without url" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key
      }
    end
  
    use "attempted PUT source with :id without params"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :url     => "http://data.gov/updated"
      }
    end
    
    use "successful PUT source with :id"
  end
  
  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/updated"
      }
    end
    
    use "successful PUT source with :id"
  end

end

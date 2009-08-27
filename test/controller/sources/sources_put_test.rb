require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesPutControllerTest < RequestTestCase

  before do
    @source = Source.create({
      :url => "http://dc.gov/original"
    })
    @id = @source.id
    @fake_id = get_fake_mongo_object_id
    @source_count = Source.count
  end

  # - - - - - - - - - -
  
  shared "unchanged url in database" do
    test "url should be unchanged in database" do
      assert_equal "http://dc.gov/original", @source.url
    end
  end

  # - - - - - - - - - -

  context "anonymous user : put /sources" do
    before do
      put "/sources/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged source count"
  end

  context "incorrect user : put /sources" do
    before do
      put "/sources/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged source count"
  end

  context "normal user : put /sources" do
    before do
      put "/sources/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end

  # - - - - - - - - - -

  context "admin user : put /sources : attempt to create : protected param 'created_at'" do
    before do
      put "/sources/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :url        => "http://dc.gov/new",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
    use "unchanged url in database"
  end

  context "admin user : put /sources : attempt to create : extra param 'junk'" do
    before do
      put "/sources/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://dc.gov/new",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
    use "unchanged url in database"
  end
  
  context "admin user : put /sources : attempt to create : correct params" do
    before do
      put "/sources/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://dc.gov/new"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
    use "unchanged url in database"
  end
  
  # - - - - - - - - - -
  
  context "admin user : put /sources : update : protected param 'updated_at'" do
    before do
      put "/sources/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :url        => "http://dc.gov/new",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged url in database"
    use "return errors hash saying updated_at is invalid"
  end
  
  context "admin user : put /sources : update : extra param 'junk'" do
    before do
      put "/sources/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://dc.gov/new",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged url in database"
    use "return errors hash saying junk is invalid"
  end

  # - - - - - - - - - -
  
  context "admin user : put /sources : update : correct params" do
    before do
      put "/sources/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://dc.gov/new",
      }
    end
  
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged source count"
  
    test "url should be updated in database" do
      source = Source.find_by_id(@id)
      assert_equal "http://dc.gov/new", source.url
    end
  end

end

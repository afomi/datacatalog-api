require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class DocumentsPutControllerTest < RequestTestCase

  before do
    @document = Document.create({
      :text => "Original Document"
    })
    @id = @document.id
    @fake_id = get_fake_mongo_object_id
    @document_count = Document.count
  end

  # - - - - - - - - - -
  
  shared "unchanged document text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Document", @document.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /documents" do
    before do
      put "/documents/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged document count"
  end

  context "incorrect API key : put /documents" do
    before do
      put "/documents/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged document count"
  end
  
  context "normal API key : put /documents" do
    before do
      put "/documents/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged document count"
  end

  # - - - - - - - - - -

  context "admin API key : put /documents : attempt to create : protected param 'create_at'" do
    before do
      put "/documents/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Document",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged document count"
    use "unchanged document text in database"
  end

  context "admin API key : put /documents : attempt to create : extra param 'junk'" do
    before do
      put "/documents/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged document count"
    use "unchanged document text in database"
  end
  
  context "admin API key : put /documents : attempt to create : correct params" do
    before do
      put "/documents/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged document count"
    use "unchanged document text in database"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : put /documents : update : protected param 'updated_at'" do
    before do
      put "/documents/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Document",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged document count"
    use "unchanged document text in database"
    use "return errors hash saying updated_at is invalid"
  end
  
  context "admin API key : put /documents : update : extra param 'junk'" do
    before do
      put "/documents/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged document count"
    use "unchanged document text in database"
    use "return errors hash saying junk is invalid"
  end

  # - - - - - - - - - -
  
  context "admin API key : put /documents : update : correct params" do
    before do
      put "/documents/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document"
      }
    end
  
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged document count"
  
    test "text should be updated in database" do
      document = Document.find_by_id(@id)
      assert_equal "New Document", document.text
    end
  end

end

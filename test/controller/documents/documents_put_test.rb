require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class DocumentsPutControllerTest < RequestTestCase

  def app; DataCatalog::Documents end

  before :all do
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

  shared "attempted PUT document with :fake_id with protected param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged document count"
    use "unchanged document text in database"
  end

  shared "attempted PUT document with :fake_id with invalid param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged document count"
    use "unchanged document text in database"
  end

  shared "attempted PUT document with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged document count"
    use "unchanged document text in database"
  end

  shared "attempted PUT document with :id with protected param" do
    use "return 400 Bad Request"
    use "unchanged document count"
    use "unchanged document text in database"
    use "return errors hash saying updated_at is invalid"
  end

  shared "attempted PUT document with :id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged document count"
    use "unchanged document text in database"
    use "return errors hash saying junk is invalid"
  end

  shared "successful PUT document with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged document count"

    test "text should be updated in database" do
      document = Document.find_by_id(@id)
      assert_equal "New Document", document.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /" do
    before do
      put "/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged document count"
  end

  context "incorrect API key : put /" do
    before do
      put "/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged document count"
  end

  context "normal API key : put /" do
    before do
      put "/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged document count"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Document",
        :created_at => Time.now.to_json
      }
    end
    
    use "attempted PUT document with :fake_id with protected param"
  end

  context "admin API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Document",
        :created_at => Time.now.to_json
      }
    end
  
    use "attempted PUT document with :fake_id with protected param"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Document",
        :junk    => "This is an extra param (junk)"
      }
    end
    
    use "attempted PUT document with :fake_id with invalid param"
  end
  
  context "admin API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT document with :fake_id with invalid param"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Document"
      }
    end
    
    use "attempted PUT document with :fake_id with correct params"
  end
    
  context "admin API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document"
      }
    end
  
    use "attempted PUT document with :fake_id with correct params"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Document",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT document with :id with protected param"
  end

  context "admin API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Document",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT document with :id with protected param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Document",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT document with :id with invalid param"
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT document with :id with invalid param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Document"
      }
    end
    
    use "successful PUT document with :id"
  end
  
  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Document"
      }
    end
    
    use "successful PUT document with :id"
  end

end

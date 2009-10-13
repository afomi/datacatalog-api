require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesPutControllerTest < RequestTestCase

  def app; DataCatalog::Notes end

  before :all do
    source = create_source
    @note = create_note(
      :text      => "Original Note",
      :source_id => source.id
    )
    @id = @note.id
    @fake_id = get_fake_mongo_object_id
    @note_count = Note.count
  end

  # - - - - - - - - - -

  shared "unchanged note text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Note", @note.text
    end
  end

  shared "attempted PUT note with :fake_id with protected param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged note count"
    use "unchanged note text in database"
  end

  shared "attempted PUT note with :fake_id with invalid param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged note count"
    use "unchanged note text in database"
  end

  shared "attempted PUT note with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged note count"
    use "unchanged note text in database"
  end

  shared "attempted PUT note with :id with protected param" do
    use "return 400 Bad Request"
    use "unchanged note count"
    use "unchanged note text in database"
    use "return errors hash saying updated_at is invalid"
  end

  shared "attempted PUT note with :id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged note count"
    use "unchanged note text in database"
    use "return errors hash saying junk is invalid"
  end

  shared "attempted PUT note with :id without params" do
    use "return 400 Bad Request"
    use "unchanged note count"
    
    test "body should say 'no_params_to_save'" do
      assert_include "no_params_to_save", parsed_response_body["errors"]
    end
  
    test "return help_text saying params are needed" do
      assert_include "cannot save without parameters", parsed_response_body["help_text"]
    end
  end
  
  shared "successful PUT note with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged note count"

    test "text should be updated in database" do
      note = Note.find_by_id(@id)
      assert_equal "New Note", note.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /:id" do
    before do
      put "/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged note count"
  end

  context "incorrect API key : put /:id" do
    before do
      put "/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged note count"
  end

  context "normal API key : put /:id" do
    before do
      put "/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged note count"
  end

  # - - - - - - - - - -

  context "anonymous : put /:fake_id" do
    before do
      put "/#{@fake_id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged note count"
  end

  context "incorrect API key : put /:fake_id" do
    before do
      put "/#{@fake_id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged note count"
  end

  context "normal API key : put /:fake_id" do
    before do
      put "/#{@fake_id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged note count"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Note",
        :created_at => Time.now.to_json
      }
    end
    
    use "attempted PUT note with :fake_id with protected param"
  end

  context "admin API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Note",
        :created_at => Time.now.to_json
      }
    end
  
    use "attempted PUT note with :fake_id with protected param"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Note",
        :junk    => "This is an extra param (junk)"
      }
    end
    
    use "attempted PUT note with :fake_id with invalid param"
  end
  
  context "admin API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT note with :fake_id with invalid param"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Note"
      }
    end
    
    use "attempted PUT note with :fake_id with correct params"
  end
    
  context "admin API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note"
      }
    end
  
    use "attempted PUT note with :fake_id with correct params"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Note",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT note with :id with protected param"
  end

  context "admin API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Note",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT note with :id with protected param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Note",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT note with :id with invalid param"
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT note with :id with invalid param"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key
      }
    end

    use "attempted PUT note with :id without params"
  end

  context "admin API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key
      }
    end

    use "attempted PUT note with :id without params"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Note"
      }
    end
    
    use "successful PUT note with :id"
  end
  
  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note"
      }
    end
    
    use "successful PUT note with :id"
  end

end

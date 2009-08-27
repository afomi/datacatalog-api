require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesPutControllerTest < RequestTestCase

  before do
    @note = Note.create({
      :text => "Original Note"
    })
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

  # - - - - - - - - - -

  context "anonymous user : put /notes" do
    before do
      put "/notes/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged note count"
  end

  context "incorrect user : put /notes" do
    before do
      put "/notes/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged note count"
  end
  
  context "normal user : put /notes" do
    before do
      put "/notes/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged note count"
  end

  # - - - - - - - - - -

  context "admin user : put /notes : attempt to create : protected param 'create_at'" do
    before do
      put "/notes/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Note",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged note count"
    use "unchanged note text in database"
  end

  context "admin user : put /notes : attempt to create : extra param 'junk'" do
    before do
      put "/notes/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged note count"
    use "unchanged note text in database"
  end
  
  context "admin user : put /notes : attempt to create : correct params" do
    before do
      put "/notes/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged note count"
    use "unchanged note text in database"
  end
  
  # - - - - - - - - - -
  
  context "admin user : put /notes : update : protected param 'updated_at'" do
    before do
      put "/notes/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Note",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged note count"
    use "unchanged note text in database"
    use "return errors hash saying updated_at is invalid"
  end
  
  context "admin user : put /notes : update : extra param 'junk'" do
    before do
      put "/notes/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged note count"
    use "unchanged note text in database"
    use "return errors hash saying junk is invalid"
  end

  # - - - - - - - - - -
  
  context "admin user : put /notes : update : correct params" do
    before do
      put "/notes/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Note"
      }
    end
  
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged note count"
  
    test "text should be updated in database" do
      note = Note.find_by_id(@id)
      assert_equal "New Note", note.text
    end
  end

end

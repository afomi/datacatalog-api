require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesPostControllerTest < RequestTestCase

  def app; DataCatalog::Notes end

  before do
    @note_count = Note.count
  end

  # - - - - - - - - - -

  shared "successful POST to notes" do
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented note count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/notes/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      assert_equal "Note A", parsed_response_body["text"]
    end
    
    test "text should be correct in database" do
      note = Note.find_by_id(parsed_response_body["id"])
      assert_equal "Note A", note.text
    end
  end
  
  # - - - - - - - - - -

  context "anonymous : post /" do
    before do
      post "/"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged note count"
  end
  
  context "incorrect API key : post /" do
    before do
      post "/", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged note count"
  end
  
  context "normal API key : post /" do
    before do
      post "/", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged note count"
  end
  
  # - - - - - - - - - -

  context "admin API key : post / with protected param" do
    before do
      post "/", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "Note A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged note count"
    use "return errors hash saying updated_at is invalid"
  end
  
  context "admin API key : post / with invalid param" do
    before do
      post "/", {
        :api_key => @admin_user.primary_api_key,
        :text    => "Note A",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged note count"
    use "return errors hash saying junk is invalid"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @curator_user.primary_api_key,
        :text    => "Note A",
      }
    end
    
    use "successful POST to notes"
  end
  
  context "admin API key : post / with correct params" do
    before do
      post "/", {
        :api_key => @admin_user.primary_api_key,
        :text    => "Note A",
      }
    end

    use "successful POST to notes"
  end

end

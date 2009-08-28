require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesDeleteControllerTest < RequestTestCase

  before do
    note = Note.create :text => "Original Note"
    @id = note.id
    @note_count = Note.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : delete /notes" do
    before do
      delete "/notes/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged note count"
  end

  context "incorrect API key : delete /notes" do
    before do
      delete "/notes/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged note count"
  end

  context "normal API key : delete /notes" do
    before do
      delete "/notes/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged note count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /notes/:fake_id" do
    before do
      delete "/notes/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged note count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /notes/:id" do
    before do
      delete "/notes/#{@id}", :api_key => @admin_user.primary_api_key
    end

    use "return 200 Ok"
    use "decremented note count"

    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end

    test "note should be deleted in database" do
      assert_equal nil, Note.find_by_id(@id)
    end
  end

  context "admin API key : double delete /users" do
    before do
      delete "/notes/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/notes/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented note count"
  
    test "note should be deleted in database" do
      assert_equal nil, Note.find_by_id(@id)
    end
  end

end

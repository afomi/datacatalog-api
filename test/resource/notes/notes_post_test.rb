require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class NotesPostControllerTest < RequestTestCase

  def app; DataCatalog::Notes end

  before do
    @note_count = Note.count
  end

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
      note = Note.find_by_id!(parsed_response_body["id"])
      assert_equal "Note A", note.text
    end
  end
  
  context "anonymous : post /" do
    before do
      source = create_source
      post "/",
        :text      => "Note A",
        :source_id => source.id
    end
    
    use "return 401 because the API key is missing"
    use "unchanged note count"
  end
  
  context "incorrect API key : post /" do
    before do
      source = create_source
      post "/",
        :api_key   => BAD_API_KEY,
        :text      => "Note A",
        :source_id => source.id
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged note count"
  end

  %w(curator normal admin).each do |role|
    context "#{role} API key : post / with correct params" do
      before do
        source = create_source
        post "/",
          :api_key   => primary_api_key_for(role),
          :text      => "Note A",
          :source_id => source.id,
          :updated_at => Time.now.to_json
      end

      use "return 400 Bad Request"
      use "unchanged note count"
      use "return errors hash saying updated_at is invalid"
    end

    context "#{role} API key : post / with correct params" do
      before do
        source = create_source
        post "/",
          :api_key   => primary_api_key_for(role),
          :text      => "Note A",
          :source_id => source.id,
          :junk      => "This is an extra param (junk)"
      end

      use "return 400 Bad Request"
      use "unchanged note count"
      use "return errors hash saying junk is invalid"
    end

    context "#{role} API key : post / with correct params" do
      before do
        source = create_source
        post "/",
          :api_key   => primary_api_key_for(role),
          :text      => "Note A",
          :source_id => source.id
      end

      use "successful POST to notes"
    end
  end

end

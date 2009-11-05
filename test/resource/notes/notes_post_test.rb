require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class NotesPostTest < RequestTestCase

  def app; DataCatalog::Notes end

  before do
    @note_count = Note.count
  end

  %w(normal).each do |role|
    context "#{role} API key : post / with correct params" do
      before do
        source = create_source
        post "/",
          :api_key   => primary_api_key_for(role),
          :text      => "Note A",
          :source_id => source.id
      end

      use "return 201 Created"
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
  end

end

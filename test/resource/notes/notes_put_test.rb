require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class NotesPutTest < RequestTestCase

  def app; DataCatalog::Notes end

  before do
    @source = create_source
    @note = create_note(
      :text      => "Original Note",
      :source_id => @source.id
    )
    @note_count = Note.count
  end

  after do
    @note.destroy
    @source.destroy
  end

  %w(normal admin).each do |role|
    context "#{role} API key : put /:id with correct param" do
      before do
        put "/#{@note.id}", {
          :api_key => primary_api_key_for(role),
          :text    => "New Note"
        }
      end

      use "return 200 Ok"
      use "unchanged note count"

      doc_properties %w(text user_id source_id id updated_at created_at)

      test "text should be updated in database" do
        note = Note.find_by_id!(@note.id)
        assert_equal "New Note", note.text
      end
    end
  end

end

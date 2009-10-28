require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Notes end

  before do
    @source = create_source
    @note = create_note(
      :source_id => @source.id
    )
    @note_count = Note.count
  end
  
  after do
    @source.destroy
  end

  context "non owner API key : delete /:id" do
    before do
      user = create_user_with_primary_key
      delete "/#{@note.id}", :api_key => user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged note count"
  end
  
  context "curator API key : delete /:id" do
    before do
      delete "/#{@note.id}", :api_key => @curator_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged note count"
  end

  context "owner API key : delete /:id" do
    before do
      delete "/#{@note.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 204 No Content"
    use "decremented note count"
    
    test "note should be deleted in database" do
      assert_equal nil, Note.find_by_id(@note.id)
    end
  end

end

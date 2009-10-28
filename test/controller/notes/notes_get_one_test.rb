require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Notes end

  before do
    @source = create_source
    @note = create_note(
      :source_id => @source.id
    )
  end
  
  after do
    @note.destroy
    @source.destroy
  end
  
  context "non owner API key" do
    before do
      user = create_user_with_primary_key
      get "/#{@note.id}", :api_key => user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
  end
  
  %w(normal).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@note.id}", :api_key => primary_api_key_for(role)
      end
  
      use "return 200 Ok"
      use "return timestamps and id in body"

      test "body should have correct text" do
        assert_equal "Sample Note", parsed_response_body["text"]
      end

      test "body should have source_id" do
        assert_include "source_id", parsed_response_body
      end

      test "body should have user_id" do
        assert_include "user_id", parsed_response_body
      end
    end
  end

end

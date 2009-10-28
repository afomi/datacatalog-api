require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Notes end

  before do
    source = create_source
    note = create_note(
      :source_id => source.id
    )
    @id = note.id
    @fake_id = get_fake_mongo_object_id
  end

  shared "attempted GET note with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
  end

  shared "successful GET note with :id" do
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

  context "get /:id" do
    context "anonymous" do
      before do
        get "/#{@id}"
      end

      use "return 401 because the API key is missing"
    end

    context "incorrect API key" do
      before do
        get "/#{@id}", :api_key => "does_not_exist_in_database"
      end

      use "return 401 because the API key is invalid"
    end
  end

  %w(normal curator admin).each do |role|
    context "#{role} API key : get /:fake_id" do
      before do
        get "/#{@fake_id}", :api_key => primary_api_key_for(role)
      end

      use "attempted GET note with :fake_id"
    end
  end
  
  %w(curator).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end

      use "return 401 because the API key is unauthorized"
    end
  end
  
  context "non owner API key" do
    before do
      user = create_user_with_primary_key
      get "/#{@id}", :api_key => user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
  end

  %w(normal admin).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end
  
      use "successful GET note with :id"
    end
  end

end

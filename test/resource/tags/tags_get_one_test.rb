require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TagsGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Tags end

  before do
    @tag = create_tag(:text => "Tag A")
  end
  
  after do
    @tag.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@tag.id}", :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
  
    test "body should have correct text" do
      assert_equal "Tag A", parsed_response_body["text"]
    end

    doc_properties %w(
      created_at
      id
      source_id
      text
      updated_at
      user_id
    )
  end

end

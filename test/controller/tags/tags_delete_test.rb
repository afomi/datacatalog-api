require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class TagsDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Tags end

  before do
    tag = Tag.create :text => "Original Tag"
    @id = tag.id
    @tag_count = Tag.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "attempted DELETE tag with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
  end

  shared "successful DELETE tag with :id" do
    use "return 200 Ok"
    use "decremented tag count"

    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end

    test "tag should be deleted in database" do
      assert_equal nil, Tag.find_by_id(@id)
    end
  end

  shared "attempted double DELETE tag with :id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented tag count"

    test "should be deleted in database" do
      assert_equal nil, Tag.find_by_id(@id)
    end
  end

  # - - - - - - - - - -

  context "anonymous : delete /" do
    before do
      delete "/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged tag count"
  end

  context "incorrect API key : delete /" do
    before do
      delete "/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged tag count"
  end

  context "normal API key : delete /" do
    before do
      delete "/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged tag count"
  end

  # - - - - - - - - - -

  context "curator API key : delete /:fake_id" do
    before do
      delete "/#{@fake_id}", :api_key => @curator_user.primary_api_key
    end
    
    use "attempted DELETE tag with :fake_id"
  end

  context "admin API key : delete /:fake_id" do
    before do
      delete "/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "attempted DELETE tag with :fake_id"
  end

  # - - - - - - - - - -

  context "curator API key : delete /:id" do
    before do
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "successful DELETE tag with :id"
  end
  
  context "admin API key : delete /:id" do
    before do
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "successful DELETE tag with :id"
  end

  # - - - - - - - - - -

  context "admin API key : double delete /users" do
    before do
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "attempted double DELETE tag with :id"
  end

  context "admin API key : double delete /users" do
    before do
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "attempted double DELETE tag with :id"
  end

end

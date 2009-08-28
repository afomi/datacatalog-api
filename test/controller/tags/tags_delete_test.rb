require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class TagsDeleteControllerTest < RequestTestCase

  before do
    tag = Tag.create :text => "Original Tag"
    @id = tag.id
    @tag_count = Tag.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : delete /tags" do
    before do
      delete "/tags/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged tag count"
  end

  context "incorrect API key : delete /tags" do
    before do
      delete "/tags/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged tag count"
  end

  context "normal API key : delete /tags" do
    before do
      delete "/tags/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged tag count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /tags/:fake_id" do
    before do
      delete "/tags/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /tags/:id" do
    before do
      delete "/tags/#{@id}", :api_key => @admin_user.primary_api_key
    end

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

  context "admin API key : double delete /users" do
    before do
      delete "/tags/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/tags/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented tag count"
  
    test "tag should be deleted in database" do
      assert_equal nil, Tag.find_by_id(@id)
    end
  end

end

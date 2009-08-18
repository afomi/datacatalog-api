require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class TagsPutControllerTest < RequestTestCase

  before do
    @tag = Tag.create({
      :text => "Original Tag"
    })
    @id = @tag.id
    @fake_id = get_fake_mongo_object_id
    @tag_count = Tag.count
  end

  # - - - - - - - - - -
  
  shared "unchanged tag text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Tag", @tag.text
    end
  end

  # - - - - - - - - - -

  context "anonymous user : put /tags" do
    before do
      put "/tags/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged tag count"
  end

  context "incorrect user : put /tags" do
    before do
      put "/tags/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged tag count"
  end
  
  context "normal user : put /tags" do
    before do
      put "/tags/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged tag count"
  end

  # - - - - - - - - - -

  context "admin user : put /tags : attempt to create : protected param 'create_at'" do
    before do
      put "/tags/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Tag",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
    use "unchanged tag text in database"
  end

  context "admin user : put /tags : attempt to create : extra param 'junk'" do
    before do
      put "/tags/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
    use "unchanged tag text in database"
  end
  
  context "admin user : put /tags : attempt to create : correct params" do
    before do
      put "/tags/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
    use "unchanged tag text in database"
  end
  
  # - - - - - - - - - -
  
  context "admin user : put /tags : update : protected param 'updated_at'" do
    before do
      put "/tags/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Tag",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged tag count"
    use "unchanged tag text in database"
  
    test "body should say 'updated_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "updated_at", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin user : put /tags : update : extra param 'junk'" do
    before do
      put "/tags/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged tag count"
    use "unchanged tag text in database"
  
    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end

  # - - - - - - - - - -
  
  context "admin user : put /tags : update : correct params" do
    before do
      put "/tags/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag"
      }
    end
  
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged tag count"
  
    test "text should be updated in database" do
      tag = Tag.find_by_id(@id)
      assert_equal "New Tag", tag.text
    end
  end

end

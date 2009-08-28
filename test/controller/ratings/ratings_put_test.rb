require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsPutControllerTest < RequestTestCase

  before do
    @rating = Rating.create({
      :text => "Original Rating"
    })
    @id = @rating.id
    @fake_id = get_fake_mongo_object_id
    @rating_count = Rating.count
  end

  # - - - - - - - - - -
  
  shared "unchanged rating text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Rating", @rating.text
    end
  end

  shared "successful ratings update" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged rating count"

    test "text should be updated in database" do
      rating = Rating.find_by_id(@id)
      assert_equal "New Rating", rating.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /ratings" do
    before do
      put "/ratings/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged rating count"
  end

  context "incorrect API key : put /ratings" do
    before do
      put "/ratings/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged rating count"
  end

  context "normal API key : put /ratings" do
    before do
      put "/ratings/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
  end

  # - - - - - - - - - -

  context "curator API key : put /ratings : attempt to create : protected param 'create_at'" do
    before do
      put "/ratings/#{@fake_id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Rating",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
    use "unchanged rating text in database"
  end

  context "admin API key : put /ratings : attempt to create : protected param 'create_at'" do
    before do
      put "/ratings/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Rating",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
    use "unchanged rating text in database"
  end

  # - - - - - - - - - -

  context "curator API key : put /ratings/:id : attempt to create : extra param 'junk'" do
    before do
      put "/ratings/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Rating",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
    use "unchanged rating text in database"
  end

  context "admin API key : put /ratings/:id : attempt to create : extra param 'junk'" do
    before do
      put "/ratings/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Rating",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
    use "unchanged rating text in database"
  end

  # - - - - - - - - - -

  context "curator API key : put /ratings/:id : attempt to create : correct params" do
    before do
      put "/ratings/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Rating"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
    use "unchanged rating text in database"
  end
  
  context "admin API key : put /ratings/:id : attempt to create : correct params" do
    before do
      put "/ratings/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Rating"
      }
    end
  
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
    use "unchanged rating text in database"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : put /ratings/:id : update : protected param 'created_at'" do
    before do
      put "/ratings/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Rating",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "unchanged rating text in database"
  
    test "body should say 'created_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "created_at", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin API key : put /ratings : update : extra param 'junk'" do
    before do
      put "/ratings/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Rating",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "unchanged rating text in database"
  
    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end

  # - - - - - - - - - -

  context "curator API key : put /ratings : update : correct params" do
    before do
      put "/ratings/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Rating"
      }
    end
    
    use "successful ratings update"
  end
  
  context "admin API key : put /ratings : update : correct params" do
    before do
      put "/ratings/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Rating"
      }
    end
    
    use "successful ratings update"
  end

end

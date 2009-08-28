require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsPostControllerTest < RequestTestCase
  
  shared "successful POST to ratings" do
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented rating count"
      
    test "location header should point to new rerating" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/ratings/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct text" do
      assert_equal "Rating A", parsed_response_body["text"]
    end
    
    test "text should be correct in database" do
      rating = Rating.find_by_id(parsed_response_body["id"])
      assert_equal "Rating A", rating.text
    end
  end

  # - - - - - - - - - -

  before do
    @rating_count = Rating.count
  end

  # - - - - - - - - - -

  context "anonymous : post /ratings" do
    before do
      post '/ratings'
    end
    
    use "return 401 because the API key is missing"
    use "unchanged rating count"
  end
  
  context "incorrect API key : post /ratings" do
    before do
      post '/ratings', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged rating count"
  end

  # - - - - - - - - - -
  
  context "normal API key : post /ratings : protected param 'created_at'" do
    before do
      post '/ratings', {
        :api_key    => @normal_user.primary_api_key,
        :text       => "Rating A",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying created_at is invalid"
  end

  context "curator API key : post /ratings : protected param 'created_at'" do
    before do
      post '/ratings', {
        :api_key    => @curator_user.primary_api_key,
        :text       => "Rating A",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying created_at is invalid"
  end
  
  context "admin API key : post /ratings : protected param 'created_at'" do
    before do
      post '/ratings', {
        :api_key    => @admin_user.primary_api_key,
        :text       => "Rating A",
        :created_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying created_at is invalid"
  end

  # - - - - - - - - - -
  
  context "normal API key : post /ratings : extra param 'junk'" do
    before do
      post '/ratings', {
        :api_key => @normal_user.primary_api_key,
        :text    => "Rating A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying junk is invalid"
  end

  context "curator API key : post /ratings : extra param 'junk'" do
    before do
      post '/ratings', {
        :api_key => @curator_user.primary_api_key,
        :text    => "Rating A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying junk is invalid"
  end

  context "admin API key : post /ratings : extra param 'junk'" do
    before do
      post '/ratings', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Rating A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying junk is invalid"
  end
  
  # - - - - - - - - - -

  context "normal API key : post /ratings : correct params" do
    before do
      post '/ratings', {
        :api_key => @normal_user.primary_api_key,
        :text    => "Rating A",
      }
    end
    
    use "successful POST to ratings"
  end

  context "curator API key : post /ratings : correct params" do
    before do
      post '/ratings', {
        :api_key => @curator_user.primary_api_key,
        :text    => "Rating A",
      }
    end
    
    use "successful POST to ratings"
  end

  context "admin API key : post /ratings : correct params" do
    before do
      post '/ratings', {
        :api_key => @admin_user.primary_api_key,
        :text    => "Rating A",
      }
    end
    
    use "successful POST to ratings"
  end

end

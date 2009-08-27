require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesRatingsPostControllerTest < RequestTestCase

  before do
    @source = Source.create({
      :url => "http://data.gov/sources/1"
    })
    @id = @source.id
    @fake_id = get_fake_mongo_object_id
    @rating_count = @source.ratings.length
  end
  
  # - - - - - - - - - -
  
  context "anonymous user : post /sources/:id/ratings" do
    before do
      post "/sources/#{@id}/ratings"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged rating count"
  end
  
  context "incorrect user : post /sources/:id/ratings" do
    before do
      post "/sources/#{@id}/ratings",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged rating count"
  end
  
  context "normal user : post /sources/:id/ratings" do
    before do
      post "/sources/#{@id}/ratings",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
  end
  
  # - - - - - - - - - -
  
  context "anonymous user : post /sources/:fake_id/ratings" do
    before do
      post "/sources/#{@fake_id}/ratings"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged rating count"
  end
  
  context "incorrect user : post /sources/:fake_id/ratings" do
    before do
      post "/sources/#{@fake_id}/ratings",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged rating count"
  end
  
  context "normal user : post /sources/:fake_id/ratings" do
    before do
      post "/sources/#{@fake_id}/ratings",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
  end
  
  # - - - - - - - - - -
  
  context "admin user : post /sources/:fake_id/ratings : correct params" do
    before do
      post "/sources/#{@fake_id}/ratings", {
        :api_key => @admin_user.primary_api_key,
        :value   => 2,
        :text    => "Rating #1"
      }
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
  end

  # - - - - - - - - - -
  
  context "admin user : post /sources/:id/ratings : correct params" do
    before do
      post "/sources/#{@id}/ratings", {
        :api_key => @admin_user.primary_api_key,
        :value   => 2,
        :text    => "Rating #1"
      }
    end
    
    use "return 201 Created"
    use "incremented rating count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/sources/#{@id}/ratings/#{parsed_response_body["id"]}"
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct value" do
      assert_equal 2, parsed_response_body["value"]
    end
      
    test "body should have correct text" do
      assert_equal "Rating #1", parsed_response_body["text"]
    end
    
    test "value should be correct in database" do
      source = Source.find_by_id(@id)
      assert_equal 2, source.ratings[0]["value"]
    end
      
    test "text should be correct in database" do
      source = Source.find_by_id(@id)
      assert_equal "Rating #1", source.ratings[0]["text"]
    end
  end

  # context "admin user : post /sources/:id/ratings : protected param ''" do
  #
  #   Not applicable...
  #
  #   Since api_key is already screened out by admin validation, it will
  #   not be passed through to the ApiKey params.
  # 
  # end
  
  context "admin user : post /sources/:id/ratings : extra param 'junk'" do
    before do
      post "/sources/#{@id}/ratings", {
        :api_key => @admin_user.primary_api_key,
        :value => 2,
        :text  => "Rating #1",
        :junk  => "This is an extra parameter (junk)"
      }
    end
    
    use "return 400 Bad Request"
    use "return errors hash saying junk is invalid"
  end

end

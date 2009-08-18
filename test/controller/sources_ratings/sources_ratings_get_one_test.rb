require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesRatingsGetOneControllerTest < RequestTestCase

  before do
    @source = Source.create({
      :url => "http://data.gov/sources/1"
    })

    @source.ratings << Rating.new(
      :value => 2,
      :text  => "Rating #1"
    )
    @source.save!

    @rating_id = @source.ratings[0].id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous user : get /sources/:id/ratings/:id" do
    before do
      get "/sources/#{@source.id}/ratings/#{@rating_id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /sources/:id/ratings/:id" do
    before do
      get "/sources/#{@source.id}/ratings/#{@rating_id}",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal user : get /sources/:id/ratings/:id" do
    before do
      get "/sources/#{@source.id}/ratings/#{@rating_id}",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  # - - - - - - - - - -

  context "admin user : get /sources/:fake_id/ratings/:id : not found" do
    before do
      get "/sources/#{@fake_id}/ratings/#{@rating_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin user : get /sources/:id/ratings/:fake_id : not found" do
    before do
      get "/sources/#{@source.id}/ratings/#{@fake_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin user : get /sources/:fake_id/ratings/:fake_id : not found" do
    before do
      get "/sources/#{@fake_id}/ratings/#{@fake_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  # - - - - - - - - - -

  context "admin user : get /sources/:id/ratings/:id : found" do
    before do
      get "/sources/#{@source.id}/ratings/#{@rating_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"

    test "body should have correct value" do
      assert_equal 2, parsed_response_body["value"]
    end

    test "body should have correct text" do
      assert_equal "Rating #1", parsed_response_body["text"]
    end

    test "body should not have _id" do
      assert_not_include "_id", parsed_response_body
    end

    test "body should have created_at" do
      assert_include "created_at", parsed_response_body
    end

    test "body should not have updated_at" do
      assert_not_include "updated_at", parsed_response_body
    end
  end

end

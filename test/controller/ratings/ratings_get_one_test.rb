require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsGetOneControllerTest < RequestTestCase

  shared "successful GET of a rating" do
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Rating A", parsed_response_body["text"]
    end
  end

  # - - - - - - - - - -

  before do
    rating = Rating.create :text => "Rating A"
    @id = rating.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : get /ratings/:id" do
    before do
      get "/ratings/#{@id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /ratings/:id" do
    before do
      get "/ratings/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  # - - - - - - - - - -

  context "normal API key : get /ratings/:fake_id : not found" do
    before do
      get "/ratings/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  context "curator API key : get /ratings/:fake_id : not found" do
    before do
      get "/ratings/#{@fake_id}", :api_key => @curator_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  context "admin API key : get /ratings/:fake_id : not found" do
    before do
      get "/ratings/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  # - - - - - - - - - -
  
  context "normal API key : get /ratings/:id" do
    before do
      get "/ratings/#{@id}", :api_key => @normal_user.primary_api_key
    end
    
    use "successful GET of a rating"
  end

  context "curator API key : get /ratings/:id" do
    before do
      get "/ratings/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "successful GET of a rating"
  end
  
  context "admin API key : get /ratings/:id" do
    before do
      get "/ratings/#{@id}", :api_key => @admin_user.primary_api_key
    end

    use "successful GET of a rating"
  end

end

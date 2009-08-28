require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsDeleteControllerTest < RequestTestCase

  before do
    rating = Rating.create :text => "Original Rating"
    @id = rating.id
    @rating_count = Rating.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "successful DELETE of a rating" do
    use "return 200 Ok"
    use "decremented rating count"

    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end

    test "rating should be deleted in database" do
      assert_equal nil, Rating.find_by_id(@id)
    end
  end

  shared "double DELETE of a rating" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented rating count"
  
    test "rating should be deleted in database" do
      assert_equal nil, Rating.find_by_id(@id)
    end
  end

  # - - - - - - - - - -

  context "anonymous : delete /ratings/:id" do
    before do
      delete "/ratings/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged rating count"
  end

  context "incorrect API key : delete /ratings/:id" do
    before do
      delete "/ratings/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged rating count"
  end

  context "normal API key : delete /ratings/:id" do
    before do
      delete "/ratings/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
  end

  # - - - - - - - - - -

  context "curator API key : delete /ratings/:fake_id" do
    before do
      delete "/ratings/#{@fake_id}", :api_key => @curator_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
  end

  context "admin API key : delete /ratings/:fake_id" do
    before do
      delete "/ratings/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged rating count"
  end

  # - - - - - - - - - -

  context "curator API key : delete /ratings/:id" do
    before do
      delete "/ratings/#{@id}", :api_key => @curator_user.primary_api_key
    end

    use "successful DELETE of a rating"
  end

  context "admin API key : delete /ratings/:id" do
    before do
      delete "/ratings/#{@id}", :api_key => @admin_user.primary_api_key
    end

    use "successful DELETE of a rating"
  end

  # - - - - - - - - - -
  
  context "curator API key : double delete /ratings" do
    before do
      delete "/ratings/#{@id}", :api_key => @curator_user.primary_api_key
      delete "/ratings/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "double DELETE of a rating"
  end

  context "admin API key : double delete /ratings" do
    before do
      delete "/ratings/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/ratings/#{@id}", :api_key => @admin_user.primary_api_key
    end

    use "double DELETE of a rating"
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsPostControllerTest < RequestTestCase

  def app; DataCatalog::Ratings end

  before do
    @rating_count = Rating.count
  end

  # - - - - - - - - - -

  shared "successful POST to ratings" do
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented rating count"
      
    test "location header should point to new resource" do
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

  context "anonymous : post /" do
    before do
      post "/"
    end
    
    use "return 401 because the API key is missing"
    use "unchanged rating count"
  end
  
  context "incorrect API key : post /" do
    before do
      post "/", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged rating count"
  end
  
  context "normal API key : post /" do
    before do
      post "/", :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged rating count"
  end
  
  # - - - - - - - - - -
  
  context "admin API key : post / with protected param 'updated_at'" do
    before do
      source = Source.create(
        :url => "http://data.gov/sources/1006"
      )
      post "/", {
        :api_key    => @admin_user.primary_api_key,
        :kind       => "source",
        :value      => 5,
        :text       => "Rating A",
        :source_id  => source.id,
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying updated_at is invalid"
  end

  context "admin API key : post / with protected param 'user_id'" do
    before do
      source = Source.create(
        :url => "http://data.gov/sources/1006"
      )
      post "/", {
        :api_key    => @admin_user.primary_api_key,
        :kind       => "source",
        :value      => 5,
        :text       => "Rating A",
        :source_id  => source.id,
        :user_id    => @normal_user.id
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying user_id is invalid"
  end
  
  context "admin API key : post / with invalid param" do
    before do
      source = Source.create(
        :url => "http://data.gov/sources/1006"
      )
      post "/", {
        :api_key   => @admin_user.primary_api_key,
        :kind      => "source",
        :value     => 5,
        :text      => "Rating A",
        :source_id => source.id,
        :junk      => "This is an extra param (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged rating count"
    use "return errors hash saying junk is invalid"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : post / with correct params" do
    before do
      source = Source.create(
        :url => "http://data.gov/sources/1006"
      )
      post "/", {
        :api_key   => @curator_user.primary_api_key,
        :kind      => "source",
        :value     => 5,
        :text      => "Rating A",
        :source_id => source.id
      }
    end
    
    use "successful POST to ratings"
  end
  
  context "admin API key : post / with correct params" do
    before do
      source = Source.create(
        :url => "http://data.gov/sources/1006"
      )
      post "/", {
        :api_key => @admin_user.primary_api_key,
        :kind      => "source",
        :value     => 5,
        :text      => "Rating A",
        :source_id => source.id,
      }
    end
  
    use "successful POST to ratings"
  end

end

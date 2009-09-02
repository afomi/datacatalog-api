require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Ratings end

  # - - - - - - - - - -
  
  shared "successful GET of 0 ratings" do
    use "return 200 Ok"
    use "return an empty response body"
  end
  
  shared "successful GET of 3 ratings" do
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "body should have correct text" do
      actual = (0 ... 3).map { |n| parsed_response_body[n]["text"] }
      3.times { |n| assert_include "Rating #{n}", actual }
    end

    test "body should have correct value" do
      actual = (0 ... 3).map { |n| parsed_response_body[n]["value"] }
      3.times { |n| assert_include n, actual }
    end
  
    3.times do |n|
      test "element #{n} should have source_id" do
        assert_include "source_id", parsed_response_body[n]
      end

      test "element #{n} should have user_id" do
        assert_include "user_id", parsed_response_body[n]
      end

      test "element #{n} should have created_at" do
        assert_include "created_at", parsed_response_body[n]
      end
        
      test "element #{n} should have updated_at" do
        assert_include "updated_at", parsed_response_body[n]
      end
      
      test "element #{n} should have id" do
        assert_include "id", parsed_response_body[n]
      end
        
      test "element #{n} should not have _id" do
        assert_not_include "_id", parsed_response_body[n]
      end
    end
  end
  
  # - - - - - - - - - -
  
  context "anonymous : get /" do
    before do
      get "/"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /" do
    before do
      get "/", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end

  # - - - - - - - - - -

  context_ "0 ratings" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of 0 ratings"
    end

    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of 0 ratings"
    end
  end

  # - - - - - - - - - -

  context_ "3 ratings" do
    before do
      3.times do |n|
        Rating.create(
          :text      => "Rating #{n}",
          :value     => n,
          :user_id   => get_fake_mongo_object_id,
          :source_id => get_fake_mongo_object_id
        )
      end
    end
    
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "successful GET of 3 ratings"
    end
  
    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end

      use "successful GET of 3 ratings"
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Ratings end

  # - - - - - - - - - -
  
  shared "successful GET of 0 ratings" do
    use "return 200 Ok"
    use "return an empty response body"
  end
  
  shared "successful GET of 7 ratings" do
    test "body should have 7 top level elements" do
      assert_equal 7, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        case element["kind"]
        when "source"
          assert_include "source_id", element
          assert_equal "source rating #{element['value']}", element["text"]
        when "comment"
          assert_include "comment_id", element
        else flunk "incorrect kind of rating"
        end
        assert_include "value", element
        assert_include "user_id", element
        assert_include "created_at", element
        assert_include "updated_at", element
        assert_include "id", element
        assert_not_include "_id", element
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

  context_ "7 ratings" do
    before do
      5.times do |n|
        assert Rating.create(
          :kind      => "source",
          :value     => n + 1,
          :text      => "source rating #{n + 1}",
          :user_id   => get_fake_mongo_object_id,
          :source_id => get_fake_mongo_object_id
        ).valid?
      end
      2.times do |n|
        assert Rating.create(
          :kind       => "comment",
          :value      => n,
          :user_id    => get_fake_mongo_object_id,
          :comment_id => get_fake_mongo_object_id
        ).valid?
      end
    end
    
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "successful GET of 7 ratings"
    end
  
    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end

      use "successful GET of 7 ratings"
    end
  end

end

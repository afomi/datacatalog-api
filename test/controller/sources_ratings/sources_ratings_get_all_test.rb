require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesRatingsGetAllControllerTest < RequestTestCase
  
  before do
    source = Source.create({
      :url => "http://data.gov/sources/1"
    })
    source.ratings = [
      Rating.new({
        :value => 2,
        :text  => "Rating #1"
      }),
      Rating.new({
        :value => 3,
        :text  => "Rating #2"
      }),
      Rating.new({
        :value => 4,
        :text  => "Rating #3"
      })
    ]
    source.save!
    @id = source.id
  end

  # - - - - - - - - - -
  
  context "anonymous user : get /sources/:id/ratings" do
    before do
      get "/sources/#{@id}/ratings"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /sources/:id/ratings" do
    before do
      get "/sources/#{@id}/ratings",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal user : get /sources/:id/ratings" do
    before do
      get "/sources/#{@id}/ratings",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end

  # - - - - - - - - - -

  context "admin user : get /sources/:id/ratings" do
    before do
      get "/sources/#{@id}/ratings",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end
    
    3.times do |n|
      test "element #{n} should have id" do
        assert_include "id", parsed_response_body[n]
      end
      
      test "element #{n} should have value" do
        assert_include "value", parsed_response_body[n]
      end

      test "element #{n} should have text" do
        assert_include "text", parsed_response_body[n]
      end
      
      test "element #{n} should not have _id" do
        assert_not_include "_id", parsed_response_body[n]
      end

      test "element #{n} should have created_at" do
        assert_include "created_at", parsed_response_body[n]
      end
          
      test "element #{n} should not have updated_at" do
        assert_not_include "updated_at", parsed_response_body[n]
      end
    end
  end
  
end

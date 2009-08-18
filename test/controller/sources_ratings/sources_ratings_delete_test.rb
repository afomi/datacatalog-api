require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesRatingsDeleteControllerTest < RequestTestCase

  before do
    @source = Source.create({
      :url => "http://data.gov/sources/1"
    })

    @ratings = [
      Rating.new({
        :value => 2,
        :text  => "Rating #1"
      }),
      Rating.new({
        :value => 3,
        :text  => "Rating #2"
      }),
      Rating.new({
        :value => 3,
        :text  => "Rating #3"
      })
    ]
    @source.ratings = @ratings
    @source.save!
    
    @rating_count = @source.ratings.length
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  3.times do |n|
    context_ "Rating key #{n}" do
      context "anonymous source : delete /sources/:id/ratings/:id" do
        before do
          delete "/sources/#{@source.id}/ratings/#{@ratings[n].id}"
        end
      
        use "return 401 because the API key is missing"
        use "unchanged rating count"
      end

      context "incorrect source : delete /sources/:id/ratings/:id" do
        before do
          delete "/sources/#{@source.id}/ratings/#{@ratings[n].id}",
            :api_key => "does_not_exist_in_database"
        end
      
        use "return 401 because the API key is invalid"
        use "unchanged rating count"
      end

      context "normal source : delete /sources/:id/ratings/:id" do
        before do
          delete "/sources/#{@source.id}/ratings/#{@ratings[n].id}",
            :api_key => @normal_user.primary_api_key
        end
    
        use "return 401 because the API key is unauthorized"
        use "unchanged rating count"
      end
      
      # - - - - - - - - - -
      
      context "admin source : delete /sources/:fake_id/ratings/:id" do
        before do
          delete "/sources/#{@fake_id}/ratings/#{@ratings[n].id}",
            :api_key => @admin_user.primary_api_key
        end

        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged rating count"
      end

      context "admin source : delete /sources/:fake_id/ratings/:fake_id" do
        before do
          delete "/sources/#{@fake_id}/ratings/#{@fake_id}",
            :api_key => @admin_user.primary_api_key
        end

        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged rating count"
      end

      context "admin source : delete /sources/:id/ratings/:fake_id" do
        before do
          delete "/sources/#{@source.id}/ratings/#{@fake_id}",
            :api_key => @admin_user.primary_api_key
        end

        use "return 404 Not Found"
        use "return an empty response body"
        use "unchanged rating count"
      end
      
      # - - - - - - - - - -
      
      context "admin source : delete /sources" do
        before do
          delete "/sources/#{@source.id}/ratings/#{@ratings[n].id}",
            :api_key => @admin_user.primary_api_key
        end
      
        use "return 200 Ok"
        use "decremented rating count"
      
        test "body should have correct id" do
          assert_include "id", parsed_response_body
          assert_equal @ratings[n].id, parsed_response_body["id"]
        end
      
        test "API key should be deleted in database" do
          source = Source.find_by_id(@source.id)
          rating = source.ratings.find { |x| x.id == @ratings[n].id }
          assert_equal nil, rating
        end
      end
      
      context "admin source : double delete /sources" do
        before do
          delete "/sources/#{@source.id}/ratings/#{@ratings[n].id}",
            :api_key => @admin_user.primary_api_key
          delete "/sources/#{@source.id}/ratings/#{@ratings[n].id}",
            :api_key => @admin_user.primary_api_key
        end
        
        use "return 404 Not Found"
        use "return an empty response body"
        use "decremented rating count"
      
        test "API key should be deleted in database" do
          source = Source.find_by_id(@source.id)
          rating = source.ratings.find { |x| x.id == @ratings[n].id }
          assert_equal nil, rating
        end
      end
      
    end
  end

end

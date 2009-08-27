require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesRatingsPutControllerTest < RequestTestCase

  context_ "user with 3 API keys" do
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
          :value => 4,
          :text  => "Rating #3"
        })
      ]
      @source.ratings = @ratings
      @source.save!

      @rating_count = @source.ratings.length
      @fake_id = get_fake_mongo_object_id
    end

    3.times do |n|
      context_ "Rating #{n}" do
        context "anonymous user : put /sources/:id/ratings/:id" do
          before do
            put "/sources/#{@source.id}/ratings/#{@ratings[n].id}"
          end
        
          use "return 401 because the API key is missing"
          use "unchanged rating count"
        end
        
        context "incorrect user : put /sources/:id/ratings/:id" do
          before do
            put "/sources/#{@source.id}/ratings/#{@ratings[n].id}",
              :api_key => "does_not_exist_in_database"
          end
        
          use "return 401 because the API key is invalid"
          use "unchanged rating count"
        end
        
        context "normal user : put /sources/:id/ratings/:id" do
          before do
            put "/sources/#{@source.id}/ratings/#{@ratings[n].id}",
              :api_key => @normal_user.primary_api_key
          end
        
          use "return 401 because the API key is unauthorized"
          use "unchanged rating count"
        end
        
        # - - - - - - - - - -
        
        context "admin user : put /sources/:fake_id/ratings/:id : attempt to create : not found" do
          before do
            put "/sources/#{@fake_id}/ratings/#{@ratings[n].id}",
              :api_key => @admin_user.primary_api_key
          end
        
          use "return 404 Not Found"
          use "return an empty response body"
          use "unchanged rating count"
        end
        
        context "admin user : put /sources/:id/ratings/:fake_id : attempt to create : not found" do
          before do
            put "/sources/#{@source.id}/ratings/#{@fake_id}",
              :api_key => @admin_user.primary_api_key
          end
        
          use "return 404 Not Found"
          use "return an empty response body"
          use "unchanged rating count"
        end
        
        context "admin user : put /sources/:fake_id/ratings/:fake_id : attempt to create : not found" do
          before do
            put "/sources/#{@fake_id}/ratings/#{@fake_id}",
              :api_key => @admin_user.primary_api_key
          end
        
          use "return 404 Not Found"
          use "return an empty response body"
          use "unchanged rating count"
        end
        
        # - - - - - - - - - -
        
        context "admin user : put /sources/:id/ratings/:id : update : protected param 'created_at'" do
          before do
            @original_created_at = @source.ratings[n].created_at.dup
            put "/sources/#{@source.id}/ratings/#{@ratings[n].id}", {
              :api_key    => @admin_user.primary_api_key,
              :value      => 2,
              :text       => "Rating #1",
              :created_at => (Time.now + 10).to_json
            }
          end
        
          use "return 400 Bad Request"
          use "unchanged rating count"
          use "return errors hash saying created_at is invalid"
        
          test "created_at should be unchanged in database" do
            source = Source.find_by_id @source.id
            assert_equal_json_times @original_created_at, source.ratings[n].created_at
          end

          test "value should be unchanged in database" do
            source = Source.find_by_id @source.id
            rating = source.ratings.find { |x| x.id == @ratings[n].id }
            assert_equal @ratings[n].value, rating.value
          end

          test "text should be unchanged in database" do
            source = Source.find_by_id @source.id
            rating = source.ratings.find { |x| x.id == @ratings[n].id }
            assert_equal @ratings[n].text, rating.text
          end
        end
        
        context "admin user : put /sources/:id/ratings/:id : update : extra param 'junk'" do
          before do
            stubbed_time = Time.now + 10
            stub(Time).now {stubbed_time}
            @original_created_at = @source.ratings[n].created_at.dup
            put "/sources/#{@source.id}/ratings/#{@ratings[n].id}", {
              :api_key => @admin_user.primary_api_key,
              :value   => 2,
              :text    => "Rating #1",
              :junk    => "This is an extra parameter (junk)"
            }
          end
        
          use "return 400 Bad Request"
          use "unchanged rating count"
          use "return errors hash saying junk is invalid"

          test "created_at should be unchanged in database" do
            source = Source.find_by_id @source.id
            assert_equal_json_times @original_created_at, source.ratings[n].created_at
          end
          
          test "value should be unchanged in database" do
            source = Source.find_by_id @source.id
            rating = source.ratings.find { |x| x.id == @ratings[n].id }
            assert_equal @ratings[n].value, rating.value
          end

          test "text should be unchanged in database" do
            source = Source.find_by_id @source.id
            rating = source.ratings.find { |x| x.id == @ratings[n].id }
            assert_equal @ratings[n].text, rating.text
          end
        end

        # - - - - - - - - - -

        context "admin user : put /sources/:id/ratings/:id : update : correct param" do
          before do
            @original_created_at = @source.ratings[n].created_at.dup
            put "/sources/#{@source.id}/ratings/#{@ratings[n].id}", {
              :api_key => @admin_user.primary_api_key,
              :value   => 5,
              :text    => "Rating #1B"
            }
          end
        
          use "return 200 Ok"
          use "unchanged rating count"

          test "created_at should be unchanged in database" do
            source = Source.find_by_id @source.id
            assert_equal_json_times @original_created_at, source.ratings[n].created_at
          end

          test "value should be updated in database" do
            source = Source.find_by_id @source.id
            rating = source.ratings.find { |x| x.id == @ratings[n].id }
            assert_equal 5, rating.value
          end

          test "text should be updated in database" do
            source = Source.find_by_id @source.id
            rating = source.ratings.find { |x| x.id == @ratings[n].id }
            assert_equal "Rating #1B", rating.text
          end
        end

      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PutSourcesControllerTest < RequestTestCase
  
  context "put /sources/_id" do
    before :all do
      reset_sources
      post '/sources', :url => "http://original.gov"
      @original = parsed_response_body
      id = parsed_response_body["_id"]
      wait_long_enough_to_change_timestamp
      put "/sources/#{id}", :url => "http://updated.gov"
      @updated = parsed_response_body
    end
    
    test "should update url" do
      assert_equal "http://updated.gov", @updated["url"]
    end
    
    test "should not change 'created_at'" do
      assert_equal_times @original["created_at"], @updated["created_at"]
    end
    
    test "should update 'updated_at'" do
      assert_different_times @original["updated_at"], @updated["updated_at"]
    end
  
    test "should not change _id" do
      assert_equal @original["_id"], @updated["_id"]
    end
  end

end

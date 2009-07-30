require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PostSourcesControllerTest < RequestTestCase

  context "post /sources" do
    before :all do
      reset_sources
      post '/sources', :url => "http://new-source.gov"
    end
    
    test "body should have correct url value" do
      assert_equal "http://new-source.gov", parsed_response_body["url"]
    end
    
    test "body should have created_at" do
      assert_include "created_at", parsed_response_body
    end
    
    test "body should have updated_at" do
      assert_include "updated_at", parsed_response_body
    end

    test "body should have _id" do
      assert_include "_id", parsed_response_body
    end
  end
  
end

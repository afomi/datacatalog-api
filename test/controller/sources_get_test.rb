require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class GetSourcesControllerTest < RequestTestCase
  
  context "get /sources with 0 sources" do
    before :all do
      reset_sources
      get '/sources'
    end
  
    test "should return []" do
      assert_equal [], parsed_response_body
    end
  end
  
  context "get /sources with 1 source" do
    before :all do
      reset_sources
      post '/sources', :url => "http://source-1.org"
      get '/sources'
    end
    
    test "body should have one top level element" do
      assert_equal parsed_response_body.length, 1
    end
    
    test "body should have correct url value" do
      assert_equal "http://source-1.org", parsed_response_body[0]["url"]
    end
  
    test "body should have created_at" do
      assert_include "created_at", parsed_response_body[0]
    end
    
    test "body should have updated_at" do
      assert_include "updated_at", parsed_response_body[0]
    end
  
    test "body should have _id" do
      assert_include "_id", parsed_response_body[0]
    end
  end
  
end

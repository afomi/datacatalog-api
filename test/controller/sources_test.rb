require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SourcesControllerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "get /sources with 0 sources" do
    include SharedTests

    before :all do
      reset_sources_data
      get '/sources'
      @body = JSON.parse(last_response.body)
    end
  
    test "should return []" do
      assert_equal [], @body
    end
  end
  
  context "post /sources" do
    include SharedTests

    before :all do
      reset_sources_data
      post '/sources', :url => "http://new-source.gov"
      @body = JSON.parse(last_response.body)
    end
    
    test "body should have correct url value" do
      assert_equal "http://new-source.gov", @body["url"]
    end
    
    test "body should have created_at" do
      assert @body.keys.include?("created_at")
    end
    
    test "body should have updated_at" do
      assert @body.keys.include?("updated_at")
    end

    test "body should have _id" do
      assert @body.keys.include?("_id")
    end
  end
  
  context "get /sources with 1 source" do
    include SharedTests
  
    before :all do
      reset_sources_data
      post '/sources', :url => "http://source-1.org"
      get '/sources'
      @body = JSON.parse(last_response.body)
    end
    
    test "body should have one top level element" do
      assert @body.length, 1
    end
    
    test "body should have correct url value" do
      assert_equal "http://source-1.org", @body[0]["url"]
    end
  
    test "body should have created_at" do
      assert @body[0].keys.include?("created_at")
    end
    
    test "body should have updated_at" do
      assert @body[0].keys.include?("updated_at")
    end
  
    test "body should have _id" do
      assert @body[0].keys.include?("_id")
    end
  end
  
  context "put /sources/_id" do
    include SharedTests
    
    before :all do
      reset_sources_data
      post '/sources', :url => "http://modify-me.gov"
      @original = JSON.parse(last_response.body)
      id = @original["_id"]
      sleep(1)
      put "/sources/#{id}", :url => "http://modified.gov"
      @body = JSON.parse(last_response.body)
    end
    
    test "body should have correct url" do
      assert_equal "http://modified.gov", @body["url"]
    end
    
    test "body should have an unchanged created_at" do
      assert_equal @original["created_at"], @body["created_at"]
    end
    
    test "body should have an updated updated_at" do
      assert_not_equal @original["updated_at"], @body["updated_at"]
    end
  
    test "body should have an unchanged _id" do
      assert_equal @original["_id"], @body["_id"]
    end
  end
  
  context "delete /sources/_id" do
    include SharedTests

    before :all do
      reset_sources_data
      post '/sources', :url => "http://delete-me.com"
      @id = JSON.parse(last_response.body)["_id"]
      delete "/sources/#{@id}"
      @body = JSON.parse(last_response.body)
    end

    test "body should have updated_at" do
      assert_equal @id, @body["_id"]
    end
  end

end

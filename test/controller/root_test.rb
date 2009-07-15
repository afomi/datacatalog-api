require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RootControllerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  context "get /" do
    include SharedTests

    before :all do
      get '/'
      @body = JSON.parse(last_response.body)
    end
    
    test "response is OK" do
      assert last_response.ok?
    end
    
    test "body has name" do
      assert_equal "National Data Catalog API", @body["name"]
    end

    test "body has creator" do
      assert_equal "The Sunlight Labs", @body["creator"]
    end

    test "body has version" do
      assert_equal 0.01, @body["version"]
    end
    
    test "body has list of resources" do
      expected = [
        {
          "sources" => "http://localhost:4567/sources"
        }
      ]
      assert_equal expected, @body["resources"]
    end
  end
end

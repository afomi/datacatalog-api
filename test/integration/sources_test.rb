require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SourcesIntegrationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before do
    reset_sources_data
  end
  
  test "should successfully add 1 source" do
    post '/sources', { :url => "http://data.gov" }
    assert last_response.ok?

    get '/sources'
    actual = JSON.parse(last_response.body)
    assert actual[0]["url"], "http://data.gov"
  end

  test "should successfully add 2 sources" do
    post '/sources', { :url => "http://data.gov" }
    assert last_response.ok?

    post '/sources', { :url => "http://www.utah.gov/data/" }
    assert last_response.ok?

    get '/sources'
    actual = JSON.parse(last_response.body)
    assert actual[0]["url"], "http://data.gov"
    assert actual[1]["url"], "http://www.utah.gov/data/"
  end
end

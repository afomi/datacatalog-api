require File.expand_path(File.dirname(__FILE__) + '/../api')
require 'test/unit'
require 'rack/test'
require 'json'
require 'context' # jeremymcanally-context

set :environment, :test

def reset_sources_data
  Source.destroy_all
end

module SharedTests
  
  def self.included(including_module)
    including_module.test "should have JSON content type" do
      assert_equal last_response.headers["Content-Type"], "application/json"
    end
  end
  
end

require File.expand_path(File.dirname(__FILE__) + '/../api')
require 'test/unit'
require 'rack/test'
require 'json'
require 'context' # jeremymcanally-context
require 'pending' # jeremymcanally-pending
require File.expand_path(File.dirname(__FILE__) + '/helpers/assert_not_in_delta')
require File.expand_path(File.dirname(__FILE__) + '/helpers/shared_tests')
require File.expand_path(File.dirname(__FILE__) + '/helpers/time_assertions')

set :environment, :test

def reset_sources_data
  Source.destroy_all
end

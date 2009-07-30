def require_relative(file)
  f = File.dirname(__FILE__) + file
  require File.expand_path(f)
end

require_relative '/../app'

require 'test/unit'
require 'rack/test'
require 'json'
require 'context' # jeremymcanally-context
require 'pending' # jeremymcanally-pending

require_dir 'test/helpers/test_helpers'
require_dir 'test/helpers/test_cases'
require_dir 'test/helpers/assertions'
require_dir 'test/helpers/shared'

set :environment, :test

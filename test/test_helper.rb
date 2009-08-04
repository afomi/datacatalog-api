def require_relative(file)
  f = File.dirname(__FILE__) + file
  require File.expand_path(f)
end

require_relative '/../app'

require 'test/unit'
require 'rack/test'
require 'json'

gem 'djsun-context', '>= 0.5.5'
require 'context'

gem 'jeremymcanally-pending', '>= 0.1'
require 'pending'

require_dir 'test/helpers/test_helpers'
require_dir 'test/helpers/test_cases'
require_dir 'test/helpers/assertions'
require_dir 'test/helpers/shared'

set :environment, :test

# It is safer to reset the database before running any tests.
# If you want to do so, uncomment the following line.
#
# Util.drop_database
#
# However, it slows things down considerably (by several seconds
# on my system). The only time I've had to worry about it is when
# I've upgraded my versions of MongoMapper.

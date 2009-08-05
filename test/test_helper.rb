require 'rubygems'
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

require_file 'config/config'
Config.environment = :test

# If you use `rake test` the database will automatically get dropped.
# If you are running tests outside of rake (e.g. in TextMate), you
# might want to drop the database here:
# Config.drop_database

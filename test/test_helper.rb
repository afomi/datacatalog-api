require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'rr'

gem 'crack', '>= 0.1.4'
require 'crack/json'

gem 'tu-context', '>= 0.5.8'
require 'tu-context'

gem 'pending', '>= 0.1.1'
require 'pending'

base = File.dirname(__FILE__)
Dir.glob(base + '/helpers/test_helpers/*.rb').each { |f| require f }
Dir.glob(base + '/helpers/test_cases/*.rb'  ).each { |f| require f }
Dir.glob(base + '/helpers/assertions/*.rb'  ).each { |f| require f }
Dir.glob(base + '/helpers/shared/*.rb'      ).each { |f| require f }

require File.dirname(__FILE__) + '/../config/config'
Config.environment = 'test'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

# If you use `rake test` the database will automatically get dropped.
# If you are running tests outside of rake (e.g. in TextMate), you
# might want to drop the database here:
Config.drop_database

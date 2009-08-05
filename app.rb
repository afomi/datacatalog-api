require 'rubygems'
require 'require_helpers'

gem 'sinatra', '>= 0.9.4'
require 'sinatra'

require_file 'config/config'

configure do
  set :config, Config.environment_config
  Config.setup
end

require_dir 'models'
require_dir 'controllers'

before do
  content_type :json
end

require_dir 'helpers'

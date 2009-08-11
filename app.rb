require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + '/require_helpers')

gem 'sinatra', '>= 0.9.4'
require 'sinatra'

require_file 'config/config'

configure do
  set :config, Config.environment_config
  Config.setup
end

require_dir 'models'
require_dir 'controllers'
require_dir 'helpers/shared'
require_dir 'helpers/controller'

before do
  content_type :json
end

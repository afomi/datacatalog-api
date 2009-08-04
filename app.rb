require 'rubygems'
require 'dir_helpers'
require 'digest/sha1'

gem 'sinatra', '>= 0.9.4'
require 'sinatra'

gem 'djsun-mongomapper', '>= 0.3.1'
require 'mongomapper'

require File.dirname(__FILE__) + "/config/config"

configure do
  set :config, Config.load_config_for_env(Sinatra::Application.environment)
end

require_dir 'util'
require_dir 'models'
require_dir 'controllers'

before do
  content_type :json
end

require_dir 'helpers'

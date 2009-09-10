require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + '/require_helpers')

gem 'sinatra', '>= 0.9.4'
require 'sinatra/base'

require_file 'config/config'

Sinatra::Base.set :config, Config.environment_config
Config.setup

require_dir 'lib'
require_dir 'models'
require_dir 'observers'
require_dir 'controllers'
require_dir 'helpers'

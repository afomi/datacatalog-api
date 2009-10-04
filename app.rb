require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + '/require_helpers')

gem 'sinatra', '>= 0.9.4'
require 'sinatra/base'

require_file 'config/config'

Sinatra::Base.set(:config, Config.environment_config)
Config.setup

gem 'rest-sinatra', ">= 0.3.2", "< 0.4.0"
require 'rest-sinatra'

require_dir 'lib'
require_dir 'model_helpers'
require_dir 'models'
require_dir 'observers'
require_dir 'controller_helpers'
require_dir 'controllers'

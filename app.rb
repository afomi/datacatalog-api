require 'rubygems'

gem 'sinatra', '>= 0.9.4'
require 'sinatra/base'

require File.dirname(__FILE__) + '/config/config'

Sinatra::Base.set(:config, Config.environment_config)
Config.setup

gem 'rest-sinatra', ">= 0.3.3", "< 0.4.0"
require 'rest-sinatra'

gem 'frequency', '>= 0.1.0'
require 'frequency'

base = File.dirname(__FILE__)
Dir.glob(base + '/lib/*.rb'               ).each { |f| require f }
Dir.glob(base + '/model_helpers/*.rb'     ).each { |f| require f }
Dir.glob(base + '/models/*.rb'            ).each { |f| require f }
Dir.glob(base + '/observers/*.rb'         ).each { |f| require f }
Dir.glob(base + '/controller_helpers/*.rb').each { |f| require f }
Dir.glob(base + '/controllers/*.rb'       ).each { |f| require f }

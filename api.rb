require 'rubygems'
require 'sinatra'
require 'mongomapper'

def require_relative(file)
  f = File.join(Sinatra::Application.root, file)
  require File.expand_path(f)
end

configure do
  require_relative 'config/configure'
end

helpers do
  require_relative 'helpers/shared'
end

require_relative 'controllers/root'
require_relative 'controllers/sources'

require 'rubygems'
require 'sinatra'
require 'app'

root_dir = File.dirname(__FILE__)

set :environment, :test
disable :run

run Sinatra::Application
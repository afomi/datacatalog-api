require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

require File.dirname(__FILE__) + '/config/config'
Dir.glob(File.dirname(__FILE__) + '/tasks/*.rake').each { |f| load f }

desc "Default: run all tests"
task :default => :test

namespace :environment do
  task :application do
    puts "Loading application environment..."
    require File.dirname(__FILE__) + '/app'
  end

  task :models do
    puts "Loading models..."
    Config.setup_mongomapper
    base = File.dirname(__FILE__)
    Dir.glob(base + '/model_helpers/*.rb').each { |f| require f }
    Dir.glob(base + '/models/*.rb'       ).each { |f| require f }
  end
end

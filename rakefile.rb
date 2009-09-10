require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require File.expand_path(File.dirname(__FILE__) + '/require_helpers')

require_file 'config/config'
load_dir 'tasks', '*.rake'

desc "Default: run all tests"
task :default => :test

namespace :environment do
  task :application do
    puts "Loading application environment..."
    require_file 'app'
  end
  
  task :models do
    puts "Loading models..."
    Config.setup_mongomapper
    require_dir 'models'
    require_dir 'observers'
  end
end

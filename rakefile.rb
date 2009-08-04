require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require 'tasks/rake_utility'
require 'dir_helpers'

load_dir 'tasks', '*.rake'

desc "Default: run all tests"
task :default => :test

task :environment do
  puts "Loading application environment"
  require File.dirname(__FILE__) + "/app"
  Config.load_config_for_env RakeUtility.current_environment
end

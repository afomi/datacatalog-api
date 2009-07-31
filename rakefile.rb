require "rake/testtask"
require 'rake/rdoctask'
require 'rcov/rcovtask'

desc "Default: run all tests"
task :default => :test

task :environment do
  require File.dirname(__FILE__) + "/config/config"
  Config.load_config_for_env(:test)
end

desc "Run tests"
task :test => %w(test:reset_db test:unit test:controller test:integration)

namespace :test do

  desc "Run unit tests"
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList["test/unit/*_test.rb"]
  end

  desc "Run controller tests"
  Rake::TestTask.new(:controller) do |t|
    t.test_files = FileList["test/controller/*_test.rb"]
  end

  desc "Run integration tests"
  Rake::TestTask.new(:integration) do |t|
    t.test_files = FileList["test/integration/*_test.rb"]
  end

  desc "Reset test database"
  task :reset_db => :environment do
    MongoMapper.connection.drop_database MongoMapper.database.name
    # There is no need to recreate the database -- this will happen
    # automatically when the first collection is created -- namely,
    # when a model is defined that mixes in MongoMapper::Document.
  end

end

# Use rcov for test coverage reports
Rcov::RcovTask.new(:rcov) do |rcov|
  rcov.pattern    = 'test/*.rb'
  rcov.output_dir = 'rcov/test'
  rcov.verbose    = true
end

# Generate documentation using rdoc
Rake::RDocTask.new do |rd|
  rd.main = "README.textile"
  rd.rdoc_files.include("app.rb", "helpers.rb", "middleware.rb")
  rd.rdoc_dir = "docs"
  rd.options << "--inline-source"
  rd.options << "--all"
end
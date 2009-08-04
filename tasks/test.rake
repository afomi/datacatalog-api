desc "Run tests"
task :test => %w(db:reset:test test:unit test:controller test:integration)

namespace :test do
  
  task :environment do
    RakeUtility.current_environment = :test
  end

  desc "Run unit tests"
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList["test/unit/*_test.rb"]
  end

  desc "Run controller tests"
  Rake::TestTask.new(:controller) do |t|
    t.test_files = FileList["test/controller/**/*_test.rb"]
  end

  desc "Run integration tests"
  Rake::TestTask.new(:integration) do |t|
    t.test_files = FileList["test/integration/*_test.rb"]
  end

end
desc "Run tests"
task :test => %w(
  db:reset:test
  test:unit
  test:functional
  test:controller
  test:integration
)

namespace :test do
  
  desc "Run unit tests"
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList["test/unit/*_test.rb"]
  end

  desc "Run functional tests"
  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList["test/functional/**/*_test.rb"]
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

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

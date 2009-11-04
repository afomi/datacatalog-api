require 'rubygems'

DEPENDENCIES = {
  'sinatra'                => ['>= 0.9.4'   , '< 1.0'],
  'mongo'                  => ['>= 0.16'    , '< 1.0'],
  'djsun-mongo_mapper'     => ['>= 0.5.8.2' , '< 0.6'],
  'sinatra_resource'       => ['>= 0.3.6'   , '< 0.4'],
  'frequency'              => ['>= 0.1.0'   , '< 0.2'],
  'crack'                  => ['>= 0.1.4' ],
  'djsun-context'          => ['>= 0.5.6' ],
  'jeremymcanally-pending' => ['>= 0.1'   ],
  'rack-test'              => ['>= 0.5.1' ],
  'rcov'                   => ['>= 0.9.6' ],
  'rr'                     => ['>= 0.10.4'],
  'timecop'                => ['>= 0.3.2' ],
}

namespace :dependencies do
  
  desc 'Check gem dependencies'
  task :check do
    missing = missing_dependencies(true)
    unless missing.empty?
      puts "\nRun `rake dependencies:install` to run the following commands:"
      missing.each do |name, reqs|
        puts "  #{install_command(name, reqs)}"
      end
      abort
    end
    
  end
  
  desc 'Install gem dependencies'
  task :install do
    missing_dependencies.each do |name, reqs|
      c = install_command(name, reqs)
      puts "  #{c}"
      system(c)
    end
  end
  
  def missing_dependencies(verbose=false)
    missing = {}
    DEPENDENCIES.each do |name, version_reqs|
      begin
        Gem.activate(name, *version_reqs)
      rescue Gem::LoadError => e
        puts e if verbose
        missing[name] = version_reqs
      end
    end
    missing
  end
  
  # Note:
  # RubyGems does not support:
  # gem install sinatra_resource -v ">= 0.2, < 0.3"
  def install_command(name, reqs=[])
    base = "gem install #{name}"
    if reqs
      base + %( -v "#{reqs[0]}")
    else
      base
    end
  end
  
end

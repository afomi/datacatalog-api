require 'rubygems'

DEPENDENCIES = {
  'sinatra'                => ['>= 1.0'],
  'mongo'                  => ['= 0.18.3'],
  'mongo_ext'              => ['= 0.18.3'],
  'mongo_mapper'           => ['= 0.7.0'],
  'sinatra_resource'       => ['>= 0.4.17', '< 0.5'],
  'frequency'              => ['>= 0.1.2', '< 0.2'],
  'crack'                  => ['>= 0.1.6' ],
  'djsun-context'          => ['>= 0.5.6' ],
  'pending'                => ['>= 0.1.1' ],
  'rack-test'              => ['>= 0.5.3' ],
  'rcov'                   => ['>= 0.9.7' ],
  'rr'                     => ['>= 0.10.5'],
  'timecop'                => ['>= 0.3.4' ],
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

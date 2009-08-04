namespace :db do
  
  def drop_database(config_env)
    require 'rubygems'
    gem 'mongodb-mongo', '>= 0.10.1'
    require 'mongo'
    hostname = config_env["mongo_hostname"]
    connection = XGen::Mongo::Driver::Mongo.new hostname
    database_name = config_env["mongo_database"]
    puts %{Dropping database "#{database_name}" at host "#{hostname}"}
    connection.drop_database database_name
  end

  desc "Create an admin user"
  task :create_admin => :environment do
    puts "Creating admin user"
    user = User.create({
      :name      => "National Data Catalog",
      :email     => "ndc@sunlightlabs.com",
      :confirmed => true,
      :admin     => true
    })
    user.generate_api_key!
  end
  
  desc 'Drop database for current environment (development unless RACK_ENV is set)'
  task :reset do
    config_env = RakeUtility.current_config_environment
    drop_database(config_env)
  end

  namespace :reset do
    desc 'Drop databases defined in config/config.yml'
    task :all do
      config = RakeUtility.config
      RakeUtility.environments.each do |env_name|
        drop_database config[env_name]
      end
    end

    desc 'Drop test database'
    task :test do
      RakeUtility.current_environment = :test
      config_env = RakeUtility.current_config_environment
      drop_database(config_env)
    end
  end
  
end

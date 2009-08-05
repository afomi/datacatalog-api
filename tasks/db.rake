namespace :db do
  
  def verbosely_drop_database
    db_name = Config.drop_database
    puts "Dropped database: #{db_name}."
  end
  
  desc "Create an admin user"
  task :create_admin => ["environment:models"] do
    puts "Creating admin user..."
    user = User.create({
      :name      => "National Data Catalog",
      :email     => "ndc@sunlightlabs.com",
      :confirmed => true,
      :admin     => true
    })
    user.add_api_key!
  end
  
  desc 'Drop database for current environment (development unless RACK_ENV is set)'
  task :reset do
    verbosely_drop_database
  end

  namespace :reset do
    desc 'Drop databases defined in config/config.yml'
    task :all do
      Config.environments.each do |env_name|
        Config.environment = env_name
        verbosely_drop_database
      end
    end

    desc 'Drop test database'
    task :test do
      Config.environment = :test
      verbosely_drop_database
    end
  end
  
end

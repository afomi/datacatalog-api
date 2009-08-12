namespace :db do
  
  def verbosely_drop_database
    db_name = Config.drop_database
    puts "Dropped database: #{db_name}."
  end
  
  def verbosely_create_admin_user
    user = User.create({
      :name      => "National Data Catalog",
      :email     => "ndc@sunlightlabs.com",
      :admin     => true
    })
    user.add_api_key!
    puts "Created an admin user:"
    verbosely_display_users [user]
  end
  
  def verbosely_display_users(users)
    users.each do |user|
      puts "  * #{user.name} (id: #{user.id})"
      user.api_keys.each do |api_key|
        puts "    - API key : #{user.primary_api_key}"
      end
    end
  end
  
  desc "Create an admin user if it does not already exist"
  task :ensure_admin => ["environment:models"] do
    users = User.find(:all, :conditions => {
      :admin => true
    })
    if users.length > 0
      puts "Found #{users.count} admin users in database:"
      verbosely_display_users users
    else
      verbosely_create_admin_user
    end
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

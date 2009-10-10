namespace :db do
  
  ADMIN_NAME = "Primary Admin"
  ADMIN_EMAIL = "admin@nationaldatacatalog.com"
  
  def verbosely_drop_database
    db_name = Config.drop_database
    puts "Dropped database: #{db_name}."
  end
  
  def verbosely_create_user(params, phrase="user")
    api_key = params.delete("primary_api_key")
    user = User.create(params)
    user.add_api_key!({
      :api_key  => api_key,
      :key_type => "primary"
    })
    puts "Created #{phrase}:"
    verbosely_display_users([user])
  end
  
  def verbosely_display_users(users)
    users.each do |user|
      puts "  * #{user.name} | id: #{user.id} | email: #{user.email}"
      user.api_keys.each do |api_key|
        puts "    - API key : #{user.primary_api_key}"
      end
    end
  end
  
  desc "Create the primary admin user if not present"
  task :ensure_admin => ["environment:models"] do
    users = User.find(:all, :conditions => {
      :name  => ADMIN_NAME,
      :admin => true
    })
    if users.length > 0
      users.each do |u|
        if u.email.nil?
          u.email = ADMIN_EMAIL
          u.save
        end
      end
      puts "Found #{users.length} users in database:"
      verbosely_display_users(users)
    else
      verbosely_create_user({
        :name  => ADMIN_NAME,
        :email => ADMIN_EMAIL,
        :admin => true
      }, "admin user")
    end
  end

  desc "Create default users if not present"
  task :ensure_default_users => ["environment:models"] do
    default_users = Config.environment_config["default_users"]
    if default_users && default_users.length > 0
      default_users.each do |default_user|
        existing_user = User.find(:first, :conditions => {
          :name => default_user["name"]
        })
        if existing_user
          puts "Found user:"
          verbosely_display_users([existing_user])
        else
          verbosely_create_user(default_user)
        end
      end
    else
      puts "No default users specified in config.yml"
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
      Config.environment = 'test'
      verbosely_drop_database
    end
  end
  
end

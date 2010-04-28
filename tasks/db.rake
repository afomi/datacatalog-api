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

  def verbosely_create_organization(params)
    parent_name = params.delete("parent_name")
    if parent_name
      parent_organization = Organization.first(:name => parent_name)
      params.merge!({ "parent_id" => parent_organization.id })
    end
    organization = Organization.create(params)
    puts "Created organization:"
    verbosely_display_organizations([organization])
  end
  
  def verbosely_display_users(users)
    users.each do |user|
      puts "  * name  : #{user.name}"
      puts "    id    : #{user.id}"
      puts "    email : #{user.email}"
      user.api_keys.each do |api_key|
        puts "    - API key : #{api_key.api_key} #{api_key.key_type}"
      end
    end
  end

  def verbosely_display_organizations(organizations)
    organizations.each do |organization|
      puts "  * name  : #{organization.name}"
      puts "    id    : #{organization.id}"
    end
  end
  
  desc "Create the primary admin user if not present"
  task :ensure_admin => ["environment:models"] do
    users = User.all(:conditions => {
      :name  => ADMIN_NAME,
      :admin => true
    })
    if users.length > 0
      users.each { |u| u.update_attributes(:email => ADMIN_EMAIL) }
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
  
  desc "Create default users and organizations as needed"
  task :ensure_defaults => [:ensure_default_users, :ensure_default_organizations]

  desc "Create default users if not present"
  task :ensure_default_users => ["environment:models"] do
    default_users = Config.default_users
    if default_users && default_users.length > 0
      default_users.each do |default_user|
        existing_user = User.first(:conditions => {
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
      puts "No default users specified in users.yml"
    end
  end

  desc "Create default organizations if not present"
  task :ensure_default_organizations => ["environment:models"] do
    default_organizations = Config.default_organizations
    if default_organizations && default_organizations.length > 0
      default_organizations.each do |default_organization|
        existing_organization = Organization.first(:conditions => {
          :name => default_organization["name"]
        })
        if existing_organization
          puts "Found organization:"
          verbosely_display_organizations([existing_organization])
        else
          verbosely_create_organization(default_organization)
        end
      end
    else
      puts "No default organizations specified in organizations.yml"
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

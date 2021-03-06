require 'rubygems'

gem 'mongo_mapper', '= 0.8.2'
require 'mongo_mapper'

module Config

  def self.setup
    setup_mongomapper
    # More application setup can go here...
  end

  def self.setup_mongomapper
    MongoMapper.connection = new_mongo_connection
    MongoMapper.database = environment_config['mongo_database']
  end

  def self.new_mongo_connection
    Mongo::Connection.new(environment_config["mongo_hostname"])
  end

  def self.drop_database
    database_name = environment_config["mongo_database"]
    new_mongo_connection.drop_database(database_name)
    database_name
  end

  def self.environment_config
    env_config = config[environment]
    unless env_config
      raise "Environment config not found for #{environment.inspect}"
    end
    env_config
  end

  def self.environment
    if @environment
      @environment
    else
      @environment = if Object.const_defined?("Sinatra")
        Sinatra::Base.environment.to_s
      else
        ENV['RACK_ENV'] || 'development'
      end
    end
  end

  def self.environment=(env)
    @environment = env
  end

  def self.environments
    config.keys
  end

  def self.config
    if @config
      @config
    else
      file = File.join(File.dirname(__FILE__), "config.yml")
      @config = YAML.load_file(file)
    end
  end

  def self.default_users
    if @default_users
      @default_users
    else
      file = File.join(File.dirname(__FILE__), "users.yml")
      @default_users = YAML.load_file(file)
    end
  end

  def self.default_organizations
    if @default_organizations
      @default_organizations
    else
      file = File.join(File.dirname(__FILE__), "organizations.yml")
      @default_organizations = YAML.load_file(file)
    end
  end

end

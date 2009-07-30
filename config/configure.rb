module Config
  def self.lookup_config
    file = File.join(File.dirname(__FILE__), "config.yml")
    env = Sinatra::Application.environment
    YAML.load_file(file)[env]
  end

  def self.setup_mongo
    c = Sinatra::Application.config
    MongoMapper.connection = XGen::Mongo::Driver::Mongo.new(c['mongo_hostname'])
    MongoMapper.database = c['mongo_database']
  end
end

configure do
  set :config, Config.lookup_config
  Config.setup_mongo
end

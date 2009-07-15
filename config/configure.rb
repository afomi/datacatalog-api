def lookup_config
  file = File.join(Sinatra::Application.root, "config", "config.yml")
  env = Sinatra::Application.environment
  YAML.load_file(file)[env]
end

def setup_mongo
  MongoMapper.connection = XGen::Mongo::Driver::Mongo.new(APP_CONFIG['mongo_hostname'])
  MongoMapper.database = APP_CONFIG['mongo_database']
end

APP_CONFIG = lookup_config
setup_mongo

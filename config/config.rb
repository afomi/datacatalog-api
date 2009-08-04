module Config
  
  def self.load_config_for_env(env)
    config = load_config(env)
    setup_mongomapper(config)
    config
  end
  
  def self.load_config(env)
    file = File.join(File.dirname(__FILE__), "config.yml")
    YAML.load_file(file)[env]
  end

  def self.setup_mongomapper(config)
    MongoMapper.connection = XGen::Mongo::Driver::Mongo.new(
      config['mongo_hostname']
    )
    MongoMapper.database = config['mongo_database']
  end

end

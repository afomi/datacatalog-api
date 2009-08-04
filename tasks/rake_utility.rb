module RakeUtility
  
  class << self

    def current_config_environment
      config_env = config[current_environment]
      raise "Environment not found" unless config_env
      config_env
    end
  
    def current_environment
      if @current_environment
        @current_environment
      else
        @current_environment = ENV['RACK_ENV'] || :development
      end
    end
    
    def current_environment=(env)
      @current_environment = env
    end
  
    def environments
      config.keys
    end
  
    def config
      if @config
        @config
      else
        file = File.join(File.dirname(__FILE__), "../config/config.yml")
        @config = YAML.load_file(file)
      end
    end
  
  end
  
end

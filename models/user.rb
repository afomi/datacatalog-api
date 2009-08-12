require 'digest/sha1'

class User
  
  include MongoMapper::Document

  many :api_keys
  ensure_index 'api_keys.api_key' # not tested

  key :name,            String
  key :email,           String,  :index => true
  key :purpose,         String
  key :admin,           Boolean, :default => false
  key :creator_api_key, String
  
  def primary_api_key
    return nil if api_keys.empty?
    api_keys[0][:api_key]
  end
  
  def secondary_api_keys
    if api_keys && api_keys.length > 1
      api_keys[1 .. -1]
    else
      []
    end
  end

  def generate_api_key
    salt = Config.environment_config["api_key_salt"]
    p1 = "#{Time.now.to_f}#{salt}#{rand(100_000_000)}"
    p2 = "#{creator_api_key}#{name}#{email}"
    Digest::SHA1.hexdigest(p1 + p2)
  end

  def add_api_key!
    key = ApiKey.new(:api_key => generate_api_key)
    self.api_keys << key
    self.save!
  end
  
  alias original_to_json to_json
  def to_json(options = nil)
    original_to_json({
      :methods => [:id, :primary_api_key, :secondary_api_keys],
      :except  => :_id
    })
  end
  
end

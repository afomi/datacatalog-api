require 'digest/sha1'

class User
  include MongoMapper::Document

  key :api_key,        String,  :index => true
  key :parent_api_key, String
  key :name,           String
  key :email,          String,  :index => true
  key :purpose,        String
  key :confirmed,      Boolean, :default => false
  key :admin,          Boolean, :default => false
  
  def generate_api_key
    salt = Config.environment_config["api_key_salt"]
    p1 = "#{Time.now.to_f}#{salt}#{rand(100_000_000)}"
    p2 = "#{parent_api_key}#{name}#{email}"
    Digest::SHA1.hexdigest(p1 + p2)
  end
  
  def generate_api_key!
    self.api_key = generate_api_key
    self.save!
  end
  
end

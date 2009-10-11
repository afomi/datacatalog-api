require 'digest/sha1'

class User
  
  include MongoMapper::Document
  class InconsistentState < RuntimeError; end

  # == Attributes

  key :name,            String
  key :email,           String
  key :curator,         Boolean, :default => false
  key :admin,           Boolean, :default => false
  key :creator_api_key, String
  timestamps!

  # == Indices

  ensure_index :email
  ensure_index 'api_keys.api_key' # not tested

  # == Associations

  many :api_keys
  many :ratings

  # == Derived Fields

  def application_api_keys
    objects = api_keys.select { |k| k.key_type == "application" }
    objects.map { |k| k.api_key }
  end

  def primary_api_key
    keys = api_keys.select { |k| k.key_type == "primary" }
    case keys.length
    when 0 then nil
    when 1 then keys[0][:api_key]
    else raise InconsistentState, "More than one primary API key found"
    end
  end
  
  def valet_api_keys
    objects = api_keys.select { |k| k.key_type == "valet" }
    objects.map { |k| k.api_key }
  end

  # == Validations

  # == Class Methods

  def self.find_by_api_key(api_key)
    find(:first, :conditions => { 'api_keys.api_key' => api_key })
    # TODO: find :all and raise exception if more than 1 result
  end

  # == Various Instance Methods

  def generate_api_key
    salt = Config.environment_config["api_key_salt"]
    p1 = "#{Time.now.to_f}#{salt}#{rand(100_000_000)}"
    p2 = "#{creator_api_key}#{name}#{email}"
    Digest::SHA1.hexdigest(p1 + p2)
  end

  # Example usage:
  #
  #   user = User.new
  #   user.add_api_key!({ :key_type => "primary" })
  #   user.add_api_key!({ :key_type => "application" })
  #   user.add_api_key!({ :key_type => "valet" })
  #   user.save
  #
  def add_api_key!(params = {})
    unless params[:api_key]
      params.merge!({ :api_key => generate_api_key })
    end
    key = ApiKey.new(params)
    self.api_keys << key
    self.save!
  end
  
  alias original_to_json to_json
  def to_json(options = nil)
    original_to_json({
      :methods => [
        :id,
        :primary_api_key,
        :application_api_keys,
        :valet_api_keys
      ],
      :except  => :_id
    })
  end
  
end

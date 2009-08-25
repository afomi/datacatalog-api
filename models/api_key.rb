class ApiKey
  
  include MongoMapper::EmbeddedDocument
  
  key :api_key,    String
  key :key_type,   String
  key :purpose,    String
  key :created_at, Time

  def initialize(attrs={})
    super
    write_attribute('created_at', Time.now.utc) unless read_attribute('created_at')
  end

  alias original_to_json to_json
  def to_json(options=nil)
    original_to_json({
      :methods => :id,
      :except  => :_id
    })
  end

end


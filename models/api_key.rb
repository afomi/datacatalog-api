class ApiKey
  
  include MongoMapper::EmbeddedDocument
  
  key :api_key, String
  key :purpose, String

  alias original_to_json to_json
  def to_json(options = nil)
    original_to_json({
      :methods => :id,
      :except  => :_id
    })
  end

end


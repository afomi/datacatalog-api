class ApiKey
  
  include MongoMapper::EmbeddedDocument

  # == Attributes

  key :api_key,    String
  key :key_type,   String
  key :purpose,    String
  key :created_at, Time

  # == Indices

  # == Associations

  # == Validations
  
  # TODO: add api_key
  # TODO: add key_type
  
  # == Class Methods

  # == Various Instance Methods

  def initialize(attrs={}, from_database=false)
    super
    unless read_attribute('created_at')
      write_attribute('created_at', Time.now.utc)
    end
  end
  
  def user
    _root_document
  end

end


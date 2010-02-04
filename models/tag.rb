class Tag

  include MongoMapper::Document

  # == Attributes

  key :text,            String
  key :source_id,       ObjectId
  key :user_id,         ObjectId
  timestamps!

  # == Indices

  # == Associations

  # == Validations

  # == Class Methods

  # == Various Instance Methods

end

class Tag

  include MongoMapper::Document

  # == Attributes

  key :text,            String
  key :source_id,       Mongo::ObjectID
  key :user_id,         Mongo::ObjectID
  timestamps!

  # == Indices

  # == Associations

  # == Validations

  # == Class Methods

  # == Various Instance Methods

end

class Tag

  include MongoMapper::Document

  # == Attributes
  key :text,            String
  key :source_id,       String
  key :user_id,         String
  timestamps!

  # == Indices

  # == Associations

  # == Derived Fields

  # == Validations

  # == Class Methods

  # == Various Instance Methods

end

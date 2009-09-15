class Organization

  include MongoMapper::Document

  # == Attributes
  key :text,           String
  key :source_id,      String
  key :user_id,        String
  key :needs_curation, Boolean, :default => false
  timestamps!

  # == Indices

  # == Associations

  # == Validations

  # == Class Methods

  # == Instance Methods

end

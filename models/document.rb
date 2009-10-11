# A collaboratively edited document, such as a wiki page.
class Document

  include MongoMapper::Document

  # == Attributes

  key :text,        String
  key :source_id,   String
  key :user_id,     String
  key :previous_id, String
  timestamps!

  # == Indices

  # == Associations

  # == Derived Fields

  # == Validations

  # == Class Methods

  # == Various Instance Methods

end

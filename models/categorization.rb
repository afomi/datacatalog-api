class Categorization

  include MongoMapper::Document

  # == Attributes

  key :source_id,   Mongo::ObjectID
  key :category_id, Mongo::ObjectID
  timestamps!

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :category

  # == Validations

  # == Class Methods

  # == Various Instance Methods

end

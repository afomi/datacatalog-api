class Categorization

  include MongoMapper::Document

  # == Attributes

  key :source_id,   ObjectId
  key :category_id, ObjectId
  timestamps!

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :category

  # == Validations

  # == Class Methods

  # == Various Instance Methods

end

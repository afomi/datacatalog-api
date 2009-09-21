class Category

  include MongoMapper::Document

  # == Attributes
  key :name, String
  timestamps!

  # == Indices

  # == Associations

  # == Validations
  validates_presence_of :name

  # == Class Methods

  # == Instance Methods

end

class Importer

  include MongoMapper::Document

  # == Attributes

  key :name,     String
  timestamps!

  # == Indices

  # == Associations

  many :imports

  protected

  # == Validations

  validates_presence_of :name

  # == Class Methods

  # == Various Instance Methods

end

class Importer

  include MongoMapper::Document

  # == Attributes

  key :name,     String
  timestamps!

  # == Indices

  # == Associations
  
  many :imports, :class_name => 'Import', :foreign_key => :importer_id
  
  protected

  # == Validations

  validates_presence_of :name

  # == Class Methods

  # == Various Instance Methods

end

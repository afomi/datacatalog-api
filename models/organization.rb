class Organization

  include MongoMapper::Document

  # == Attributes
  key :name,           String
  key :abbreviation,   String
  key :description,    String
  key :url,            String
  key :source_id,      String
  key :user_id,        String
  key :needs_curation, Boolean, :default => false
  timestamps!

  # == Indices

  # == Associations
  many :sources

  # == Derived Attributes

  # == Validations
  validates_presence_of :name
  validate :validate_url
  include UrlValidator

  # == Class Methods

  # == Various Instance Methods

end

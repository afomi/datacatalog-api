class Source

  include MongoMapper::Document

  # == Attributes
  key :url,           String
  key :ratings_total, Integer, :default => 0
  key :ratings_count, Integer, :default => 0
  timestamps!

  # == Indices
  ensure_index :url

  # == Associations
  many :ratings
  
  # == Validations
  validates_presence_of :url

  # == Class Methods

  # == Instance Methods
  
end

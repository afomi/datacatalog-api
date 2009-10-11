# A comment by a user about a source.
class Comment

  include MongoMapper::Document

  # == Attributes
  key :text,          String
  key :source_id,     String
  key :user_id,       String
  key :ratings_total, Integer, :default => 0
  key :ratings_count, Integer, :default => 0
  timestamps!

  # == Indices

  # == Associations
  many :ratings

  # == Validations
  validates_presence_of :text
  validates_presence_of :source_id
  validates_presence_of :user_id

  # == Class Methods

  # == Various Instance Methods

end

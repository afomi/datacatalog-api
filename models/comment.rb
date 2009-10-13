# A comment by a user about a source.
class Comment

  include MongoMapper::Document
  include Renderable
  include Ratable

  # == Attributes

  key :text,          String
  key :source_id,     String
  key :user_id,       String
  timestamps!

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :user
  many :ratings

  # == Derived Fields

  # == Validations

  validates_presence_of :text
  validates_presence_of :source_id
  validates_presence_of :user_id

  # == Class Methods

  # == Various Instance Methods

end

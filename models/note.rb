# A note by a particular user about a data source.
#
#   source_id points to the associated source.
#   user_id points to the most recent editor.
class Note

  include MongoMapper::Document
  include Renderable

  # == Attributes

  key :text,      String
  key :source_id, String
  key :user_id,   String
  timestamps!
  
  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :user

  # == Derived Attributes

  # == Validations

  validates_presence_of :text
  validates_presence_of :source_id
  validates_presence_of :user_id

  validate :general_validation

  def general_validation
    if user.nil?
      errors.add(:user_id, "must be valid")
    end
    if source.nil?
      errors.add(:source_id, "must be valid")
    end
  end

  # == Class Methods

  # == Various Instance Methods

end

# A collaboratively edited document, such as a wiki page.
#
#   source_id points to the associated source.
#   previous_id points to the previous draft.
#   user_id points to the most recent editor.
class Document

  include MongoMapper::Document
  include Renderable

  # == Attributes

  key :text,        String
  key :source_id,   String
  key :user_id,     String
  key :previous_id, String
  timestamps!

  # == Indices

  # == Associations
  
  belongs_to :source
  belongs_to :user

  # == Derived Fields

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

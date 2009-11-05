class Favorite

  include MongoMapper::Document

  # == Attributes

  key :source_id, String
  key :user_id,   String
  timestamps!
  
  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :user

  # == Validations

  validates_presence_of :source_id
  validates_presence_of :user_id

  validate :general_validation

  def general_validation
    errors.add(:user_id, "must be valid") if user.nil?
    errors.add(:source_id, "must be valid") if source.nil?
  end
  protected :general_validation

  # == Class Methods

  # == Various Instance Methods

end

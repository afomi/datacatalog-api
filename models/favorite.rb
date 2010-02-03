class Favorite

  include MongoMapper::Document

  # == Attributes

  key :source_id, Mongo::ObjectID
  key :user_id,   Mongo::ObjectID
  timestamps!
  
  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :user

  protected
  
  # == Validations

  validates_presence_of :source_id
  validates_presence_of :user_id

  validate :general_validation
  def general_validation
    errors.add(:user_id, "must be valid") if user.nil?
    errors.add(:source_id, "must be valid") if source.nil?
  end

  # == Class Methods

  # == Various Instance Methods

end

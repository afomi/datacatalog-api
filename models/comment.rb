# A comment by a user about a source.
class Comment

  include MongoMapper::Document
  include Ratable

  # == Attributes

  key :text,            String
  key :reports_problem, Boolean
  key :source_id,       Mongo::ObjectID
  key :user_id,         Mongo::ObjectID
  key :parent_id,       Mongo::ObjectID
  timestamps!

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :user
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Comment'
  many :ratings
  
  protected

  # == Validations

  validates_presence_of :text
  validates_presence_of :source_id
  validates_presence_of :user_id

  validate :general_validation
  def general_validation
    errors.add(:user_id, "must be valid") if user.nil?
    errors.add(:source_id, "must be valid") if source.nil?
    errors.add(:parent_id, "must be valid") if parent_id && parent.nil?
  end

  # == Class Methods

  # == Various Instance Methods

end

# A user can rate a source and/or a comment.
#
# kind    | values        | required keys
# ----    | ------        | -------------
# comment | 0, +1         | user_id, value, comment_id
# source  | 1, 2, 3, 4, 5 | user_id, value, text, source_id
#
class Rating

  include MongoMapper::Document

  # == Attributes
  key :kind,           String
  key :user_id,        String
  key :source_id,      String
  key :comment_id,     String
  key :value,          Integer
  key :previous_value, Integer, :default => 0
  key :text,           String
  timestamps!

  # == Indices

  # == Associations
  belongs_to :user
  belongs_to :source
  belongs_to :comment

  # == Validations
  validates_presence_of :user_id
  validates_presence_of :value
  validate :general_validation

  def general_validation
    if user.nil?
      errors.add(:user_id, "must be valid")
    end
    case kind
    when "comment" then comment_validation
    when "source"  then source_validation
    else errors.add(:kind, "is invalid")
    end
  end
  
  def comment_validation
    if comment_id.blank?
      errors.add(:comment_id, "can't be empty")
    end
    if comment.nil?
      errors.add(:comment_id, "must be valid")
    end
    unless value >= 0 && value <= 1
      errors.add(:value, "must be 0 or 1")
    end
    unless text.blank?
      errors.add(:text, "must be empty")
    end
  end
  protected :comment_validation
  
  def source_validation
    if source_id.blank?
      errors.add(:source_id, "can't be empty")
    end
    if source.nil?
      errors.add(:source_id, "must be valid")
    end
    unless value >= 1 && value <= 5
      errors.add(:value, "must be between 1 and 5")
    end
  end
  protected :source_validation

  # == Class Methods

  # == Various Instance Methods
  def find_rated_document
    case self.kind
    when "comment" then self.comment
    when "source"  then self.source
    end
  end
  
  def find_rated_document!
    doc = case self.kind
    when "comment" then self.comment
    when "source"  then self.source
    else raise "Invalid kind of rating"
    end
    raise "Associated #{self.kind} not found" if doc.nil?
    doc
  end

end

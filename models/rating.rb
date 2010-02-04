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
  key :user_id,        ObjectId
  key :source_id,      ObjectId
  key :comment_id,     ObjectId
  key :value,          Integer
  key :previous_value, Integer, :default => 0
  key :text,           String
  timestamps!

  # == Indices

  # == Associations

  belongs_to :user
  belongs_to :source
  belongs_to :comment

  protected

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
    errors.add(:comment_id, "can't be empty") if comment_id.blank?
    errors.add(:comment_id, "must be valid") if comment.nil?
    errors.add(:value, "must be 0 or 1") unless value == 0 || value == 1
    errors.add(:text, "must be empty") unless text.blank?
  end
  
  def source_validation
    errors.add(:source_id, "can't be empty") if source_id.blank?
    errors.add(:source_id, "must be valid") if source.nil?
    unless value >= 1 && value <= 5
      errors.add(:value, "must be between 1 and 5")
    end
  end

  # == Callbacks

  after_create :stats_after_create
  def stats_after_create
    doc = self.find_rated_document!
    stale = doc.rating_stats
    count = (doc.rating_stats[:count] += 1)
    total = (doc.rating_stats[:total] += self.value)
    doc.rating_stats[:average] = total.to_f / count
    doc.save!
  end
  
  before_update :stats_before_update
  def stats_before_update
    rating_from_db = Rating.find_by_id(self.id)
    self.previous_value = rating_from_db.value if rating_from_db
  end
  
  after_update :stats_after_update
  def stats_after_update
    doc = self.find_rated_document!
    value_delta = self.value - self.previous_value
    total = (doc.rating_stats[:total] += value_delta)
    count = doc.rating_stats[:count]
    doc.rating_stats[:average] = total.to_f / count
    doc.save
  end
  
  after_destroy :stats_after_destroy
  def stats_after_destroy
    doc = self.find_rated_document
    return if doc.nil?
    count = (doc.rating_stats[:count] -= 1)
    doc.rating_stats[:total] -= self.value
    doc.rating_stats[:average] = nil if count == 0
    doc.save
  end

  # == Class Methods

  # == Various Instance Methods

  def find_rated_document
    case self.kind
    when "comment" then self.comment
    when "source"  then self.source
    else raise "Invalid kind of rating"
    end
  end
  
  def find_rated_document!
    doc = find_rated_document
    raise Error, "Associated #{self.kind} not found" if doc.nil?
    doc
  end

end

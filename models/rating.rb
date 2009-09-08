# A user can rate a source.
#
# kind    | values        | required keys
# ----    | ------        | -------------
# comment | 0, +1         | user_id, value, comment_id
# source  | 1, 2, 3, 4, 5 | user_id, value, text, source_id
#
class Rating

  include MongoMapper::Document

  key :kind,       String
  key :user_id,    String,  :required => true
  key :source_id,  String
  key :comment_id, String
  key :value,      Integer, :required => true
  key :text,       String
  timestamps!

  belongs_to :user
  belongs_to :source
  belongs_to :comment
  
  validate :general_validation
  
  def general_validation
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
    unless value >= 0 && value <= 1
      errors.add(:value, "must be 0 or 1")
    end
    unless text.blank?
      errors.add(:text, "must be empty")
    end
  end
  
  def source_validation
    if source_id.blank?
      errors.add(:source_id, "can't be empty")
    end
    unless value >= 1 && value <= 5
      errors.add(:value, "must be between 1 and 5")
    end
  end

end

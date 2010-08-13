class Categorization

  include MongoMapper::Document

  # == Attributes

  key :source_id,   ObjectId
  key :category_id, ObjectId
  timestamps!

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :category

  # == Validations
  
  validates_presence_of :source_id
  validates_presence_of :category_id
  
  validate :general_validation
  def general_validation
    errors.add(:source_id, "must be valid") if source.nil?
    errors.add(:category_id, "must be valid") if category.nil?
  end
  
  # == Class Methods

  # == Various Instance Methods

end

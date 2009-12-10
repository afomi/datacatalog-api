# Sources that are of type "dataset" can have one or more downloads that point
# to the physical dataset files.
class Download

  include MongoMapper::Document

  # == Attributes

  key :url,       String
  key :format,    String
  key :preview,   String
  key :source_id, String
  timestamps!
  
  # == Indices

  # == Associations

  belongs_to :source

  # == Validations

  include UrlValidator

  validates_presence_of :format
  validates_presence_of :url
  validates_presence_of :source_id
  validate :validate_url

  validate :general_validation
  def general_validation
    errors.add(:source_id, "must be valid") if source.nil?
  end
  protected :general_validation

  validate :validate_source_type
  def validate_source_type
    unless source.source_type == "dataset"
      errors.add(:source, "must have dataset source_type")
    end
  end
  protected :validate_source_type

  # == Class Methods

  # == Various Instance Methods

end

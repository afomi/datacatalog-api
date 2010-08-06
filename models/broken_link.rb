class BrokenLink

  include MongoMapper::Document

  # == Attributes

  key :source_id,       ObjectId # if applicable
  key :organization_id, ObjectId # if applicable
  key :field,           String   # corresponding metadata field
  key :destination_url, String   # the URL that is broken
  key :status,          Integer  # HTTP status code (e.g. 404)
  timestamps!
  # created_at : time of original breakage
  # updated_at : time of last check

  # == Indices

  # == Associations

  belongs_to :source
  belongs_to :organization

  # == Validations

  validates_presence_of :field
  validates_presence_of :destination_url
  validates_presence_of :status
  
  validate :validate_source_or_organization
  def validate_source_or_organization
    if !source_id && !organization_id
      errors.add(:base, "source_id or organization_id needed")
    elsif source_id && organization_id
      errors.add(:base, "source_id and organization_id cannot both be set")
    end
  end

  # == Class Methods

  # == Various Instance Methods

end

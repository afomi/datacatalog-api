class Import

  include MongoMapper::Document

  # == Attributes

  key :importer_id,  Mongo::ObjectID
  key :status,       String # see STATUS_TYPES below
  key :start_time,   Time
  key :finish_time,  Time
  timestamps!

  # == Indices
  
  ensure_index :importer_id
  ensure_index :finish_time

  # == Associations
  
  belongs_to :importer
  
  protected

  # == Validations

  validates_presence_of :importer_id
  validates_presence_of :start_time
  validates_presence_of :finish_time

  STATUS_TYPES = %w(success failure)

  validate :validate_status
  def validate_status
    unless STATUS_TYPES.include?(status)
      errors.add(:status, "must be one of: #{STATUS_TYPES.join(', ')}")
    end
  end

  # == Class Methods

  # == Various Instance Methods
  
  public
  
  def duration
    finish_time - start_time
  end

end

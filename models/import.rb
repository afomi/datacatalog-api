class Import

  include MongoMapper::Document

  # == Attributes

  key :importer_id,  ObjectId
  key :status,       String # see STATUS_TYPES below
  key :started_at,   Time
  key :finished_at,  Time
  key :duration,     Float
  timestamps!

  # == Indices
  
  ensure_index :importer_id
  ensure_index :finished_at
  ensure_index :duration

  # == Associations
  
  belongs_to :importer
  
  protected

  # == Validations

  validates_presence_of :importer_id
  validates_presence_of :started_at
  validates_presence_of :finished_at

  STATUS_TYPES = %w(success failure)

  validate :validate_status
  def validate_status
    unless STATUS_TYPES.include?(status)
      errors.add(:status, "must be one of: #{STATUS_TYPES.join(', ')}")
    end
  end
  
  # == Callbacks
  
  after_validation :update_duration
  def update_duration
    if started_at && finished_at
      self.duration = finished_at - started_at
    end
  end

  # == Class Methods

  # == Various Instance Methods

end

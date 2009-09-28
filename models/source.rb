class Source

  include MongoMapper::Document

  # == Attributes
  key :title,           String
  key :url,             String
  key :released,        Time
  key :period_start,    Time
  key :period_end,      Time
  key :frequency,       String,  :default => ""
  key :ratings_total,   Integer, :default => 0
  key :ratings_count,   Integer, :default => 0
  key :organization_id, String
  key :custom,          Hash
  timestamps!

  # == Indices
  ensure_index :url

  # == Associations
  many :ratings
  belongs_to :organization
  
  # == Validations
  validates_presence_of :title
  validates_presence_of :url
  validate :validate_url
  include UrlValidator
  validate :validate_period
  validate :validate_frequency
  
  def validate_period
    return if !period_start && !period_end
    if period_start && !period_end
      errors.add(:period_end, "is required if period_start given")
    elsif period_end && !period_start
      errors.add(:period_start, "is required if period_end given")
    elsif period_start > period_end
      errors.add(:period_end, "must be later than period_start")
    end
  end
  
  FREQUENCIES = {
    "weekly"     => 52,
    "monthly"    => 12,
    "quarterly"  => 4,
    "biannually" => 2,
    "annually"   => 1,
    "yearly"     => 1,
    "unknown"    => nil,
    "irregular"  => nil,
    ""           => nil
  }
  
  def validate_frequency
    unless FREQUENCIES.keys.include?(frequency)
      errors.add(:frequency, "is invalid")
    end
  end

  # == Class Methods

  # == Instance Methods
  def updates_per_year
    FREQUENCIES[frequency]
  end
  
end

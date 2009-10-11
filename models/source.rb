class Source

  include MongoMapper::Document

  # == Attributes
  key :title,           String
  key :url,             String
  key :released,        Time
  key :period_start,    Time
  key :period_end,      Time
  key :frequency,       String
  key :ratings_total,   Integer, :default => 0
  key :ratings_count,   Integer, :default => 0
  key :organization_id, String
  key :custom,          Hash
  key :raw,             Hash
  timestamps!

  # == Indices
  ensure_index :url

  # == Associations
  many :ratings
  many :categorizations
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
    "each second"  => 31_536_000,
    "each minute"  =>    525_600,
    "each hour"    =>      8_760,
    "each day"     =>        365,
    "each week"    =>         52,
    "each month"   =>         12,
    "each quarter" =>          4,
    "each year"    =>          1,
    "hourly"       =>      8_760,
    "daily"        =>        365,
    "weekly"       =>         52,
    "monthly"      =>         12,
    "quarterly"    =>          4,
    "biannually"   =>          2,
    "annually"     =>          1,
    "yearly"       =>          1,
    "other"        =>        nil,
    "unknown"      =>        nil,
  }
  
  def validate_frequency
    if frequency && !FREQUENCIES.keys.include?(frequency)
      errors.add(:frequency, "is invalid")
    end
  end

  # == Class Methods

  # == Derived Fields
  def categories
    categorizations.map do |categorization|
      categorization.category
    end
  end
  
  def category_names
    categorizations.map do |categorization|
      categorization.category.name
    end
  end
  
  def updates_per_year
    FREQUENCIES[frequency]
  end
  
  # == JSON Output
  alias original_to_json to_json
  def to_json(options = nil)
    original_to_json({
      :methods => [
        :updates_per_year,
        :category_names,
      ],
    })
  end
  
end

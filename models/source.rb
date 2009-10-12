class Source

  include MongoMapper::Document
  include Renderable

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

  belongs_to :organization
  many :categorizations
  many :comments
  many :ratings

  def categories
    categorizations.map(&:category)
  end
  
  # == Derived Attributes

  derived_key :category_ids
  def category_ids
    categorizations.map do |categorization|
      categorization.category.id
    end
  end

  derived_key :category_names
  def category_names
    categorizations.map do |categorization|
      categorization.category.name
    end
  end

  derived_key :updates_per_year
  def updates_per_year
    FREQUENCIES[frequency]
  end
  
  derived_key :comment_details
  def comment_details
    comments.map do |comment|
      {
        "href" => "/comments/#{comment.id}",
        "text" => comment.text,
        "user" => {
          "name" => comment.user.name,
          "href" => "/users/#{comment.user.id}",
        }
      }
    end
  end
  
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
  
  # == Various Instance Methods
  
end

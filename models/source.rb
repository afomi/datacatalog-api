gem 'frequency', '>= 0.1.2', '< 0.2.0'
require 'frequency'

class Source

  include MongoMapper::Document
  include Ratable

  # == Attributes

  key :title,               String
  key :slug,                String
  key :description,         String
  key :source_type,         String
  key :license,             String
  key :catalog_name,        String
  key :url,                 String
  key :documentation_url,   String
  key :license_url,         String
  key :catalog_url,         String
  key :released,            Hash
  key :period_start,        Time
  key :period_end,          Time
  key :frequency,           String
  key :organization_id,     String
  key :custom,              Hash
  key :raw,                 Hash
  key :_keywords,           Array
  timestamps!

  # == Indices

  ensure_index :title
  ensure_index :slug
  ensure_index :source_type
  ensure_index :license
  ensure_index :url

  # == Associations

  belongs_to :organization
  many :categorizations
  many :comments
  many :documents
  many :favorites
  many :notes
  many :ratings
  many :downloads

  def categories
    categorizations.map(&:category)
  end

  # == Validations

  validates_presence_of :title
  validates_presence_of :url
  validates_uniqueness_of :slug

  validates_format_of :slug,
    :with      => /\A[a-zA-z0-9\-]+\z/,
    :message   => "can only contain alphanumeric characters and dashes",
    :allow_nil => true

  include UrlValidator
  validate :validate_url

  SOURCE_TYPES = %w(
    api
    dataset
  )

  validate :validate_source_type
  def validate_source_type
    unless SOURCE_TYPES.include?(source_type)
      errors.add(:source_type, "must be one of: #{SOURCE_TYPES.join(', ')}")
    end
  end
  protected :validate_source_type

  validate :validate_period
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
  protected :validate_period

  validate :validate_frequency
  def validate_frequency
    if frequency && !Frequency.new(frequency).valid?
      errors.add(:frequency, "is invalid")
    end
  end
  protected :validate_frequency

  # == Callbacks
  
  before_validation :handle_blank_slug
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end
  protected :handle_blank_slug
  
  before_create :generate_slug
  def generate_slug
    return if title.blank?
    default = Slug.make(title, self)
    self.slug = default if slug.blank?
    n = 2
    loop do
      existing = self.class.first(:slug => slug)
      break unless existing
      self.slug = "#{default}-#{n}"
      n += 1
    end
  end
  protected :generate_slug
  
  before_save :update_keywords
  def update_keywords
    self._keywords = DataCatalog::Search.process([title, description])
  end
  protected :update_keywords
  
  RELEASED_KEYS = %w(day month year)
  MIN_YEAR = 1900
  MAX_YEAR = Time.now.year
  
  validate :validate_released
  def validate_released
    if (released.keys - RELEASED_KEYS).length > 0
      errors.add(:released, "only these keys are allowed : #{RELEASED_KEYS}")
    end

    year  = released['year']
    month = released['month']
    day   = released['day']

    validate_integer(year,  :released, :year)
    validate_integer(month, :released, :month)
    validate_integer(day,   :released, :day)
    
    if !year.blank? && !((MIN_YEAR .. MAX_YEAR) === year)
      errors.add(:released, "year must be between #{MIN_YEAR} and #{MAX_YEAR}")
    end
    if !month.blank? && !((1 .. 12) === month)
      errors.add(:released, "month must be between 1 and 12")
    end
    if !day.blank? && !((1 .. 31) === day)
      errors.add(:released, "day must be between 1 and 31")
    end
    
    if !day.blank? && month.blank?
      errors.add(:released, "month required if day is present")
    end
    if !day.blank? && year.blank?
      errors.add(:released, "year required if day is present")
    end
    if !month.blank? && year.blank?
      errors.add(:released, "year required if month is present")
    end
  end
  protected :validate_released
  
  def validate_integer(x, field, subfield)
    return if x.blank?
    unless x.is_a?(Integer)
      errors.add(field, "#{subfield} must be an integer if present")
    end
  end

  # == Class Methods

  # == Various Instance Methods
  
end

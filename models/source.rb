gem 'frequency', '>= 0.1.2', '< 0.2.0'
require 'frequency'

class Source

  include MongoMapper::Document
  include Ratable
  include Validators

  # == Attributes

  key :title,               String
  key :slug,                String
  key :description,         String
  key :source_type,         String
  key :url,                 String
  key :documentation_url,   String
  key :license,             String
  key :license_url,         String
  key :catalog_name,        String
  key :catalog_url,         String
  key :released,            Hash
  key :period_start,        Time
  key :period_end,          Time
  key :frequency,           String
  key :organization_id,     ObjectId
  key :jurisdiction_id,     ObjectId
  key :source_group_id,     ObjectId
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
  ensure_index :jurisdiction_id
  
  # == Associations
  
  belongs_to :organization
  belongs_to :jurisdiction, :class_name => 'Organization'
  belongs_to :source_group
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
  
  protected
  
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
  
  validate :validate_frequency
  def validate_frequency
    if frequency && !Frequency.new(frequency).valid?
      errors.add(:frequency, "is invalid")
    end
  end
  
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
  
    expect_integer(year,  :released, :year)
    expect_integer(month, :released, :month)
    expect_integer(day,   :released, :day)
    
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
  
  before_validation :handle_blank_slug
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end
  
  # == Callbacks
  
  before_create :generate_slug
  def generate_slug
    return unless slug.blank?
    return if title.blank?
    self.slug = Slug.make(title, self)
  end
  
  before_save :update_keywords
  def update_keywords
    self._keywords = DataCatalog::Search.process([title, description])
  end

  before_validation :clean_released
  def clean_released
    released.each do |key, value|
      self.released[key] = begin
        Integer(value)
      rescue ArgumentError
        value
      end
    end
  end

  after_save :set_jurisdiction
  def set_jurisdiction
    self.jurisdiction = nil
    if current_org = self.organization
      until current_org.top_level || current_org.parent.nil?
        current_org = current_org.parent
      end 
      self.jurisdiction = current_org if current_org.top_level
    end
  end

  # == Callbacks : source_count

  after_create :increment_source_count
  def increment_source_count
    adjust_source_count(self, 1)
  end

  after_destroy :decrement_source_count
  def decrement_source_count
    adjust_source_count(self, -1)
  end
  
  before_update :save_previous
  def save_previous
    @previous_source = Source.first(:_id => self.id)
  end
  
  after_update :restore_previous
  def restore_previous
    adjust_source_count(@previous_source, -1) if @previous_source
    adjust_source_count(self, 1)
  end
  
  # == Class Methods
  
  # == Various Instance Methods
  
  def adjust_source_count(source, delta)
    org = source.organization
    if org
      if org.source_count
        org.source_count += delta
      else
        org.source_count = delta
      end
      org.save!
    end
  end

end

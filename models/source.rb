gem 'frequency', '>= 0.1.0', '< 0.2.0'
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
  key :released,            Time
  key :period_start,        Time
  key :period_end,          Time
  key :frequency,           String
  key :organization_id,     String
  key :custom,              Hash
  key :raw,                 Hash
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
  many :notes
  many :ratings

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

  validate :validate_url
  include UrlValidator
  validate :validate_period
  validate :validate_frequency

  validate :validate_source_type

  SOURCE_TYPES = %w(
    api
    dataset
  )

  def validate_source_type
    unless SOURCE_TYPES.include?(source_type)
      errors.add(:source_type, "must be one of: #{SOURCE_TYPES.join(', ')}")
    end
  end

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

  def validate_frequency
    if frequency && !Frequency.new(frequency).valid?
      errors.add(:frequency, "is invalid")
    end
  end

  # == Callbacks
  
  before_validation :handle_blank_slug
  before_create :generate_slug
  
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end
  
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

  # == Class Methods

  # == Various Instance Methods
  
end

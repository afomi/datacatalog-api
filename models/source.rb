gem 'frequency', '>= 0.1.2', '< 0.2.0'
require 'frequency'

gem 'kronos', '>= 0.1.6'
require 'kronos'

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
  key :period_start,        Hash
  key :period_end,          Hash
  key :frequency,           String
  key :broken_links,        Hash
  key :organization_id,     ObjectId
  key :jurisdiction_id,     ObjectId
  key :source_group_id,     ObjectId
  key :catalog_id,          ObjectId
  key :custom,              Hash
  key :raw,                 Hash
  key :versions,            Hash
  key :_keywords,           Array
  key :score,               Integer
  timestamps!

  # == Indices

  ensure_index :title
  ensure_index :slug
  ensure_index :source_type
  ensure_index :license
  ensure_index :url
  ensure_index :jurisdiction_id
  ensure_index :catalog_id

  # == Associations

  belongs_to :organization
  belongs_to :jurisdiction, :class_name => 'Organization'
  belongs_to :source_group
  belongs_to :catalog
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
    interactive
  )

  validate :validate_source_type
  def validate_source_type
    unless SOURCE_TYPES.include?(source_type)
      errors.add(:source_type, "must be one of: #{SOURCE_TYPES.join(', ')}")
    end
  end

  validate :validate_frequency
  def validate_frequency
    if frequency && !Frequency.new(frequency).valid?
      errors.add(:frequency, "is invalid")
    end
  end

  validate :validate_released
  def validate_released
    expect_kronos_hash(released, :released)
  end

  validate :validate_period
  def validate_period
    p1 = period_start.blank? ? nil : period_start
    p2 = period_end.blank?   ? nil : period_end
    if !p1 && !p2
      return
    elsif p1 && !p2
      errors.add(:period_end, "is required if period_start given")
    elsif !p1 && p2
      errors.add(:period_start, "is required if period_end given")
    elsif p1 && p2
      expect_kronos_hash(p1, :period_start)
      expect_kronos_hash(p2, :period_end)
      k1 = Kronos.from_hash(p1)
      k2 = Kronos.from_hash(p2)
      errors.add(:period_start, "must be valid") unless k1.valid?
      errors.add(:period_end,   "must be valid") unless k2.valid?
      return unless k1.valid? && k2.valid?
      unless k1 < k2
        errors.add(:period_start, "must be earlier than period_end")
      end
    else
      raise "Unexpected"
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
    words = [title, description]
    if organization
      words << organization.name if organization.name
      words.concat(organization.names) if organization.names
      words << organization.acronym if organization.acronym
    end
    self._keywords = DataCatalog::Search.process(words)
  end

  before_validation :clean_date_fields
  def clean_date_fields
    self.released     = Clean.kronos_hash(released)
    self.period_start = Clean.kronos_hash(period_start)
    self.period_end   = Clean.kronos_hash(period_end)
  end

  before_save :set_jurisdiction
  def set_jurisdiction
    self.jurisdiction = calculate_jurisdiction
  end
  
  before_save :update_score
  def update_score
    self.score = calculate_score
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

  # == Callbacks : source_count

  after_create :increment_source_count
  def increment_source_count
    adjust_source_count(self, 1)
  end

  after_destroy :decrement_source_count
  def decrement_source_count
    adjust_source_count(self, -1)
  end

  # == Class Methods

  # == Various Instance Methods

  public

  def calculate_jurisdiction
    current_org = self.organization
    return nil unless current_org
    until current_org.top_level || current_org.parent.nil?
      current_org = current_org.parent
    end
    return nil unless current_org.top_level
    current_org
  end
  
  SCORED_FIELDS = [
    :title,
    :description,
    :source_type,
    :url,
    :documentation_url,
    :license,
    :license_url,
    :catalog_name,
    :catalog_url,
    :released,
    :period_start,
    :period_end,
    :frequency,
  ]

  def calculate_score
    score = 0
    SCORED_FIELDS.each do |field|
      value = self[field]
      if value && !value.empty?
        score += 1
      end
    end
    score
  end

  protected

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

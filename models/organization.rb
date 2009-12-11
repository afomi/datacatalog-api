 class Organization

  include MongoMapper::Document
  
  # == Attributes

  key :name,           String
  key :names,          Array
  key :acronym,        String
  key :org_type,       String
  key :description,    String
  key :slug,           String
  key :url,            String
  key :user_id,        String
  key :interest,       Integer
  key :level,          Integer
  key :custom,         Hash
  key :raw,            Hash
  key :_keywords,      Array
  key :source_count,   Integer, :default => 0

  timestamps!

  # == Indices

  # == Associations

  many :sources

  # == Validations

  include UrlValidator

  validates_presence_of :name
  validate :validate_url
  validate :validate_org_type
  validates_uniqueness_of :slug
  validates_format_of :slug,
    :with      => /\A[a-zA-z0-9\-]+\z/,
    :message   => "can only contain alphanumeric characters and dashes",
    :allow_nil => true

  ORG_TYPES = %w(
    commercial
    governmental
    not-for-profit
  )

  def validate_org_type
    unless ORG_TYPES.include?(org_type)
      errors.add(:org_type, "must be one of: #{ORG_TYPES.join(', ')}")
    end
  end
  protected :validate_org_type

  # == Callbacks

  before_validation :handle_blank_slug
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end
  protected :handle_blank_slug
  
  before_create :generate_slug
  def generate_slug
    return if name.blank?
    acronym.blank? ? to_slug = name : to_slug = acronym
    default = Slug.make(to_slug, self)
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
    self._keywords = DataCatalog::Search.process(
      names + [name, acronym, description])
  end
  protected :update_keywords

  # == Class Methods

  # == Various Instance Methods

end

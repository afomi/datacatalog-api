class Jurisdiction
  
  include MongoMapper::Document
  
  # == Attributes

  key :name,              String
  key :description,       String
  key :slug,              String
  key :url,               String
  key :user_id,           ObjectId
  key :org_count,         Integer, :default => 0

  timestamps!

  # == Indices

  # == Associations

  many :organizations

  protected
  
  # == Validations

  include UrlValidator

  validates_presence_of :name
  validate :validate_url
  validates_uniqueness_of :slug
  validates_format_of :slug,
    :with      => /\A[a-zA-z0-9\-]+\z/,
    :message   => "can only contain alphanumeric characters and dashes",
    :allow_nil => true

  # == Callbacks

  before_validation :handle_blank_slug
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end
  
  before_create :generate_slug
  def generate_slug
    return unless slug.blank?
    return if name.blank?
    self.slug = Slug.make(name, self)
  end

  # == Class Methods

  # == Various Instance Methods

end

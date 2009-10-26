class Organization

  include MongoMapper::Document
  include Renderable

  # == Attributes

  key :name,           String
  key :acronym,        String
  key :org_type,       String, :default => 'Governmental' # or Non-governmental or Company
  key :description,    String
  key :slug,           String
  key :url,            String
  key :source_id,      String
  key :user_id,        String
  key :needs_curation, Boolean, :default => false
  timestamps!

  # == Indices

  # == Associations

  many :sources

  # == Derived Attributes

  # == Callbacks
  
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

  # == Validations

  validates_presence_of :name
  validate :validate_url
  validates_format_of :org_type, :with => /\A(Governmental|Non-governmental|Company)\z/, 
    :message => "must be Governmental, Non-governmental, or Company"
  include UrlValidator

  validates_uniqueness_of :slug

  validates_format_of :slug,
    :with      => /\A[a-zA-z0-9\-]+\z/,
    :message   => "can only contain alphanumeric characters and dashes",
    :allow_nil => true

  # == Class Methods

  # == Various Instance Methods

end

class Organization

  include MongoMapper::Document
  include Renderable

  # == Attributes

  key :name,           String
  key :acronym,        String
  key :org_type,       String, :default => 'Governmental' # or Non-governmental or Company
  key :description,    String
  key :url,            String
  key :source_id,      String
  key :user_id,        String
  key :needs_curation, Boolean, :default => false
  timestamps!

  # == Indices

  # == Associations

  many :sources

  # == Derived Attributes

  # == Validations

  validates_presence_of :name
  validate :validate_url
  validates_format_of :org_type, :with => /\A(Governmental|Non-governmental|Company)\z/, 
    :message => "must be Governmental, Non-governmental, or Company"
  include UrlValidator

  # == Class Methods

  # == Various Instance Methods

end

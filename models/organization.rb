class Organization

  include MongoMapper::Document
  
  # == Attributes

  key :name,              String
  key :names,             Array
  key :acronym,           String
  key :org_type,          String
  key :description,       String
  key :slug,              String
  key :url,               String
  key :home_url,          String
  key :catalog_name,      String
  key :catalog_url,       String
  key :user_id,           ObjectId
  key :parent_id,         ObjectId
  key :top_parent_id,     ObjectId
  key :interest,          Integer
  key :top_level,         Boolean, :default => false
  key :custom,            Hash
  key :raw,               Hash
  key :_keywords,         Array
  key :source_count,      Integer, :default => 0

  timestamps!

  # == Indices

  # == Associations

  belongs_to :parent, :class_name => 'Organization'
  
  many :sources
  many :children, :class_name => 'Organization', :foreign_key => :parent_id

  protected
  
  # == Validations

  include UrlValidator

  validates_presence_of :name
  validate :validate_url
  validate :validate_org_type
  validates_format_of :slug,
    :with      => /\A[a-zA-z0-9\-]+\z/,
    :message   => "can only contain alphanumeric characters and dashes",
    :allow_nil => true
  validate :validate_slug

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
  
  def validate_slug
    return unless slug
    conflicts = self.class.all({
      :top_parent_id => top_parent_id, :slug => slug})
    conflicts.reject! { |o| o.id == id } # remove self from list
    if conflicts.count > 0
      errors.add(:slug, "has already been taken")
      if conflicts.count > 1
        raise Error, "The database contains duplicate slugs: #{slug}"
      end
    end
  end

  # == Callbacks
  
  before_validation :handle_blank_slug
  def handle_blank_slug
    self.slug = nil if self.slug.blank?
  end

  before_validation :update_top_parent_id
  def update_top_parent_id
    self.top_parent_id = get_top_parent_id
  end
  
  before_create :generate_slug
  def generate_slug
    return unless slug.blank?
    return if name.blank?
    text = acronym.blank? ? name : acronym
    self.slug = Slug.make(text, self,
      { :top_parent_id => top_parent_id })
  end
  
  before_save :update_keywords
  def update_keywords
    self._keywords = DataCatalog::Search.process(
      names + [name, acronym, description])
  end

  # == Class Methods

  # == Various Instance Methods
  
  def get_top_parent_id(max_generations = 10)
    k = 0
    org = self
    while
      k += 1
      if k > max_generations
        raise DataCatalog::Error, "Top-level parent of #{self.id} not found"
      end
      if org.top_level
        return org.id
      elsif org.parent_id
        org = org.parent
      else
        return nil
      end
    end
  end
end

gem 'frequency', '>= 0.1.0'
require 'frequency'

class Source

  include MongoMapper::Document
  include Renderable
  include Ratable

  # == Attributes

  key :title,               String
  key :slug,                String 
  key :description,         String
  key :type,                String, :default => 'Dataset' # other is 'API'
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
  ensure_index :type
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

  # == Derived Attributes

  derived_key :category_details
  def category_details
    categorizations.map do |categorization|
      {
        "href" => "/categories/#{categorization.category.id}",
        "name" => categorization.category.name,
      }
    end
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
        },
        "rating_stats" => comment.rating_stats,
      }
    end
  end

  derived_key :document_details
  def document_details
    documents.map do |document|
      {
        "href" => "/documents/#{document.id}",
        "text" => document.text,
        "user" => {
          "name" => document.user.name,
          "href" => "/users/#{document.user.id}",
        }
      }
    end
  end

  derived_key :updates_per_year
  def updates_per_year
    Frequency.new(frequency).per_year
  end

  derived_key :note_details
  def note_details
    notes.map do |note|
      {
        "href" => "/notes/#{note.id}",
        "text" => note.text,
        "user" => {
          "name" => note.user.name,
          "href" => "/users/#{note.user.id}",
        }
      }
    end
  end

  derived_key :rating_details
  def rating_details
    ratings.map do |rating|
      {
        "href"  => "/ratings/#{rating.id}",
        "text"  => rating.text,
        "value" => rating.value,
        "user"  => {
          "name" => rating.user.name,
          "href" => "/users/#{rating.user.id}",
        }
      }
    end
  end

  # == Callbacks
  before_validation :check_slug
  
  def check_slug
    if self.slug.nil? || self.slug == ""
      if self.title =~ /[:alnum:]/ 
        self.slug = slugify(self.title)
      else
        self.slug = 'data-source'
      end
    end
    existing_sources = self.class.all(:conditions => {:slug => Regexp.new(self.slug.gsub(/[^a-z0-9\-]+/i,'') || "")})
    self.slug = self.slug + "-" + existing_sources.length.to_s if existing_sources.length > 0 && !existing_sources.include?(self)
    true
  end

  # == Validations

  validates_presence_of :title
  validates_presence_of :url
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /\A[a-zA-z0-9\-]+\z/, :message => "can only contain alphanumeric characters and dashes"
  validates_format_of :type, :with => /\A(API|Dataset)\z/, :message => "must be 'API' or 'Dataset'"

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

  def validate_frequency
    if frequency && !Frequency.new(frequency).valid?
      errors.add(:frequency, "is invalid")
    end
  end

  # == Class Methods

  # == Various Instance Methods
  
  # Adapted from ActiveSupport's parameterize
  # http://github.com/rails/rails/blob/ea0e41d8fa5a132a2d2771e9785833b7663203ac/activesupport/lib/active_support/inflector.rb#L259
  def slugify(str, sep = '-')
    return self.id.to_s if str.nil? || str == ""
    to_slug = str.dup
    to_slug.gsub!(/[^a-z0-9]+/i, sep)
    unless sep.nil? || sep == ''
      re_sep = Regexp.escape(sep)
      to_slug.gsub!(/#{re_sep}{2,}/, sep)
      to_slug.gsub!(/^#{re_sep}|#{re_sep}$/i, '')
    end
    return to_slug.downcase
  end
  
end

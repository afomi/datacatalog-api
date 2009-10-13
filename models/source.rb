gem 'frequency', '>= 0.1.0'
require 'frequency'

class Source

  include MongoMapper::Document
  include Renderable

  # == Attributes

  key :title,           String
  key :url,             String
  key :released,        Time
  key :period_start,    Time
  key :period_end,      Time
  key :frequency,       String
  key :ratings_total,   Integer, :default => 0
  key :ratings_count,   Integer, :default => 0
  key :organization_id, String
  key :custom,          Hash
  key :raw,             Hash
  timestamps!

  # == Indices

  ensure_index :url

  # == Associations

  belongs_to :organization
  many :categorizations
  many :comments
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
        }
      }
    end
  end

  derived_key :updates_per_year
  def updates_per_year
    Frequency.new(frequency).per_year
  end
  
  # == Validations

  validates_presence_of :title
  validates_presence_of :url
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
  
end

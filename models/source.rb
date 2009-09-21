class Source

  include MongoMapper::Document

  # == Attributes
  key :title,         String
  key :url,           String
  key :released,      Date
  key :period_start,  Date
  key :period_end,    Date
  key :frequency,     String
  key :ratings_total, Integer, :default => 0
  key :ratings_count, Integer, :default => 0
  timestamps!

  # == Indices
  ensure_index :url

  # == Associations
  many :ratings
  
  # == Validations
  validates_presence_of :title
  validates_presence_of :url
  validate :validate_url

  def validate_url
    return unless url
    uri = URI.parse(url)
    unless uri.absolute?
      errors.add(:url, "URI must be absolute")
    end
    unless %w(http ftp).include?(uri.scheme)
      errors.add(:url, "URI scheme must be http or ftp")
    end
  rescue URI::InvalidURIError => e
    errors.add(:url, "Invalid URI: #{e})")
  end

  # == Class Methods

  # == Instance Methods
  
end

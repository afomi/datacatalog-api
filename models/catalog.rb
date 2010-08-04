# Corresponds to an online data catalog. Not every Catalog is associated with
# an Importer, because some may be entered manually.
class Catalog

  include MongoMapper::Document

  # == Attributes

  key :title,         String
  key :url,           String
  key :score_stats,   Hash, :default => {
    'total'   => nil,
    'count'   => 0,
    'average' => nil
  }

  timestamps!

  # == Indices

  ensure_index :url

  # == Associations

  many :sources

  # == Validations

  validates_presence_of :title
  validates_presence_of :url

  validates_uniqueness_of :title
  validates_uniqueness_of :url

  include UrlValidator
  validate :validate_url

end

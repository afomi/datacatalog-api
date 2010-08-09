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

  # == Class Methods

  # == Various Instance Methods

  def add_score(score)
    total = (score_stats['total'] || 0) + score
    count = (score_stats['count'] || 0) + 1
    self.score_stats = {
      'total'   => total,
      'count'   => count,
      'average' => total / count,
    }
  end

  def remove_score(score)
    unless score_stats['total'] && score_stats['count'] &&
      score_stats['count'] > 0
      raise DataCatalog::Error, "Cannot remove a score since there are none"
    end
    total = score_stats['total'] - score
    count = score_stats['count'] - 1
    self.score_stats = {
      'total'   => count > 0 ? total : nil,
      'count'   => count,
      'average' => count > 0 ? (total / count) : nil
    }
  end

  def update_score(new_score, old_score)
    add_score(new_score)
    remove_score(old_score)
  end

end

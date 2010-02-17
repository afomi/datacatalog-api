require File.dirname(__FILE__) + '/source_snippet'

class SourceGroup

  include MongoMapper::Document

  # == Attributes

  key :title,         String
  key :slug,          String
  key :description,   String
  key :_keywords,     Array
  timestamps!

  # == Indices

  ensure_index :title
  ensure_index :slug
  ensure_index :source_count

  # == Associations

  many :source_snippets

  # == Almost-Associations
  
  # An expensive calculation, avoid using if possible.
  def sources
    source_snippets.map do |source_snippet|
      Source.find(source_snippet.source_id)
    end
  end
  
  # Convenience method that automatically generates SourceSnippets and
  # points the Source back to the SourceGroup.
  def sources=(sources)
    self.source_snippets = sources.map do |source|
      SourceSnippet.new_from_source(source)
    end
    sources.each do |source|
      source.source_group = self
    end
  end
  
  protected

  # == Validations

  validates_presence_of :title
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
    return if title.blank?
    default = Slug.make(title, self)
    self.slug = default if slug.blank?
    n = 2
    loop do
      existing = self.class.first(:slug => slug)
      break unless existing
      self.slug = "#{default}-#{n}"
      n += 1
    end
  end
  
  before_save :update_keywords
  def update_keywords
    self._keywords = DataCatalog::Search.process([title, description])
  end
  
  # == Class Methods

  # == Various Instance Methods

  
end

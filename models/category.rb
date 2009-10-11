class Category

  include MongoMapper::Document
  include Renderable

  # == Attributes

  key :name, String
  timestamps!

  # == Indices

  # == Associations

  many :categorizations

  def sources
    categorizations.map(&:source)
  end

  # == Derived Fields
  
  derived_key :source_ids
  def source_ids
    categorizations.map do |categorization|
      categorization.source.id
    end
  end

  # == Validations

  validates_presence_of :name

  # == Class Methods

  # == Various Instance Methods

end

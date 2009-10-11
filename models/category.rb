class Category

  include MongoMapper::Document

  # == Attributes
  key :name, String
  timestamps!

  # == Indices

  # == Associations
  many :categorizations

  # == Validations
  validates_presence_of :name

  # == Class Methods

  # == Derived Fields
  def sources
    categorizations.map(&:source)
  end
  # == Various Instance Methods

end

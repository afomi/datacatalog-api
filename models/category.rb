class Category

  include MongoMapper::Document

  # == Attributes
  key :name, String
  timestamps!

  # == Indices

  # == Associations
  many :categorizations

  # == Derived Fields

  def sources
    categorizations.map(&:source)
  end

  # == Validations
  validates_presence_of :name

  # == Class Methods

  # == Various Instance Methods

end

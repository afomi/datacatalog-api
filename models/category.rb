class Category

  include MongoMapper::Document

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

  # == Validations

  validates_presence_of :name

  # == Class Methods

  # == Various Instance Methods

end

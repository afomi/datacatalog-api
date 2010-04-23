class SearchEvent

  include MongoMapper::Document

  # == Attributes

  key :words,      Array
  key :created_at, Time

  # == Indices
  
  ensure_index :words
  ensure_index :created_at

  # == Associations

  # == Validations

  # == Callbacks

  before_create :update_timestamp
  def update_timestamp
    self[:created_at] = Time.now.utc
  end

  # == Class Methods

  # == Various Instance Methods

end

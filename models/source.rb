class Source

  include MongoMapper::Document

  key :url,           String,  :index => true
  key :ratings_total, Integer, :default => 0
  key :ratings_count, Integer, :default => 0
  timestamps!

  many :ratings

end

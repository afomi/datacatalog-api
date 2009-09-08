class Source

  include MongoMapper::Document

  key :url, String, :index => true
  timestamps!

  many :ratings

end

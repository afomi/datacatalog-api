class Source

  include MongoMapper::Document

  key :url, String, :index => true
  many :ratings

end

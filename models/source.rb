class Source
  include MongoMapper::Document
  
  key :url, String
  ensure_index :url
end

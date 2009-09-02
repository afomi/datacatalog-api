class Tag

  include MongoMapper::Document

  key :text,            String
  key :source_id,       String
  key :user_id,         String
  timestamps!

end

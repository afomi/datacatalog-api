# A comment by a user about a source.
class Comment

  include MongoMapper::Document

  key :text,          String,  :required => true
  key :source_id,     String,  :required => true
  key :user_id,       String,  :required => true
  key :ratings_total, Integer, :default => 0
  key :ratings_count, Integer, :default => 0
  timestamps!

  many :ratings

end

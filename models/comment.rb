# A comment by a user about a source.
class Comment

  include MongoMapper::Document

  key :text,      String,  :required => true
  key :source_id, String,  :required => true
  key :user_id,   String,  :required => true
  timestamps!

  many :ratings

end

# A comment by a user about a source.
class Comment

  include MongoMapper::Document

  key :text,      String
  key :source_id, String
  key :user_id,   String
  timestamps!

end

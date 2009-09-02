# A user can rate a source.
class Rating

  include MongoMapper::Document

  key :value,      Integer
  key :text,       String
  key :user_id,    String
  key :source_id,  String

end

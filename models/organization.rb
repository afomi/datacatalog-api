class Organization

  include MongoMapper::Document

  key :text,           String
  key :source_id,      String
  key :user_id,        String
  key :needs_curation, Boolean, :default => false

end

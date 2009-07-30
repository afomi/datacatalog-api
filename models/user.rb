class User
  include MongoMapper::Document

  key :api_key,        String,  :index => true
  key :parent_api_key, String
  key :name,           String
  key :email,          String,  :index => true
  key :purpose,        String
  key :confirmed,      Boolean, :default => false
  key :admin,          Boolean, :default => false
end

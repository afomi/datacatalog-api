module VariousHelpers
  
  def wait_long_enough_to_change_timestamp
    sleep 1.0
  end

  # Returns a well-formed document id that does not correspond to
  # an existing document.
  #
  # Why is this important?
  #
  # Document#find_by_id (and related finders, probably) will raise
  # MongoMapper::DocumentNotFound if you pass in malformed id's.
  #
  # So, if you want to generate a document id that intentionally does
  # not exist in the database, you have to take care that it is well-
  # formed.
  def get_fake_mongo_object_id
    XGen::Mongo::Driver::ObjectID.new.to_s
  end
  
  def get_fake_api_key(string)
    Digest::SHA1.hexdigest(string)
  end
  
end

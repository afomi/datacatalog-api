module VariousHelpers
  
  def sleep_enough_for_mongo_timestamps_to_differ
    delay = Test::Unit::Assertions::MONGODB_TIME_GRANULARITY
    sleep delay
  end

  def sleep_enough_for_json_timestamps_to_differ
    delay = Test::Unit::Assertions::JSON_TIME_GRANULARITY
    sleep delay
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

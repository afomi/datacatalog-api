module VariousHelpers
  
  def sleep_enough_for_mongo_timestamps_to_differ
    delay = Test::Unit::Assertions::MONGODB_TIME_GRANULARITY
    sleep delay
  end

  def sleep_enough_for_json_timestamps_to_differ
    delay = Test::Unit::Assertions::JSON_TIME_GRANULARITY
    sleep delay
  end

  # Returns a document id that does not correspond to an existing document.
  def get_fake_mongo_object_id
    XGen::Mongo::Driver::ObjectID.new.to_s
  end
  
  def get_fake_api_key(string)
    Digest::SHA1.hexdigest(string)
  end
  
end

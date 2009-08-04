module Util

  def self.drop_database
    MongoMapper.connection.drop_database MongoMapper.database.name
  end

end

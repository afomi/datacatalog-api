require File.expand_path(File.dirname(__FILE__) + '/../test_resource_helper')

class IndexTest < Test::Unit::TestCase
  include DataCatalog

  context "Indexes" do
    before do
      config = Config.environment_config
      connection = Mongo::Connection.new(config["mongo_hostname"])
      db_name = config["mongo_database"]
      @db = connection.db(db_name)
    end
    
    test "source" do
      indexes = indexes_for_collection('sources')
      %w(license title url source_type slug _id).each do |expected|
        assert_include expected, indexes
      end
    end

    test "user" do
      indexes = indexes_for_collection('users')
      %w(api_keys.api_key email _id).each do |expected|
        assert_include expected, indexes
      end
    end
    
    def indexes_for_collection(collection_name)
      collection = @db.collection(collection_name)
      info = collection.index_information
      info.map { |k, v| v[0][0] } # undocumented, may be brittle
    end
  end
  
end

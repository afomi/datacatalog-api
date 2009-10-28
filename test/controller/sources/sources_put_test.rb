require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesPutControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before :all do
    @source = Source.create({
      :title => "Just a data source",
      :url   => "http://data.gov/original"
    })
    @id = @source.id
    @fake_id = get_fake_mongo_object_id
    @source_count = Source.count
  end

  shared "unchanged source text in database" do
    test "url should be unchanged in database" do
      assert_equal "http://data.gov/original", @source.url
    end
  end

  shared "attempted PUT source with :fake_id with protected param" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged source text in database"
  end

  shared "attempted PUT source with :fake_id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged source text in database"
  end

  shared "attempted PUT source with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
    use "unchanged source text in database"
  end

  shared "attempted PUT source with :id with protected param" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged source text in database"
    use "return errors hash saying updated_at is invalid"
  end

  shared "attempted PUT source with :id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "unchanged source text in database"
    use "return errors hash saying junk is invalid"
  end
  
  shared "attempted PUT source with :id with invalid url" do
    use "return 400 Bad Request"
    use "unchanged source count"
    use "return errors hash saying url scheme is incorrect"
  end

  shared "attempted PUT source with :id without params" do
    use "return 400 Bad Request"
    use "unchanged source count"
    
    test "body should say 'no_params'" do
      assert_include "no_params", parsed_response_body["errors"]
    end
  end

  shared "successful PUT to sources" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged source count"

    test "url should be updated in database" do
      source = Source.find_by_id(@id)
      assert_equal "http://data.gov/updated", source.url
    end
  end

  def create_source_with_three_custom_fields
    source = Source.find_by_id(@id)
    source.custom = {
      "0" => {
        "label"       => "custom 0",
        "description" => "description 0",
        "type"        => "string",
        "value"       => "HR-57"
      },
      "1" => {
        "label"       => "custom 1",
        "description" => "description 1",
        "type"        => "integer",
        "value"       => "100"
      },
      "2" => {
        "label"       => "custom 2",
        "description" => "description 2",
        "type"        => "date",
        "value"       => "2009-09-28"
      },
    }
    source.save
    raise "Source expected to be valid" unless source.valid?
  end

  context "put /:id" do
    context "anonymous" do
      before do
        put "/#{@id}"
      end
  
      use "return 401 because the API key is missing"
      use "unchanged source count"
    end
  
    context "incorrect API key" do
      before do
        put "/#{@id}", :api_key => "does_not_exist_in_database"
      end
  
      use "return 401 because the API key is invalid"
      use "unchanged source count"
    end
  
    context "normal API key" do
      before do
        put "/#{@id}", :api_key => @normal_user.primary_api_key
      end
  
      use "return 401 because the API key is unauthorized"
      use "unchanged source count"
    end
  end
  
  context "put /:fake_id" do
    context "anonymous" do
      before do
        put "/#{@fake_id}"
      end
  
      use "return 401 because the API key is missing"
      use "unchanged source count"
    end
  
    context "incorrect API key" do
      before do
        put "/#{@fake_id}", :api_key => "does_not_exist_in_database"
      end
  
      use "return 401 because the API key is invalid"
      use "unchanged source count"
    end
  
    context "normal API key" do
      before do
        put "/#{@fake_id}", :api_key => @normal_user.primary_api_key
      end
  
      use "return 401 because the API key is unauthorized"
      use "unchanged source count"
    end
  end
  
  %w(curator admin).each do |role|
    context "#{role} API key : put /:fake_id with protected param" do
      before do
        put "/#{@fake_id}", {
          :api_key    => primary_api_key_for(role),
          :url        => "http://data.gov/updated",
          :created_at => Time.now.to_json
        }
      end
      
      use "attempted PUT source with :fake_id with protected param"
    end
      
    context "#{role} API key : put /:fake_id with invalid param" do
      before do
        put "/#{@fake_id}", {
          :api_key => primary_api_key_for(role),
          :url     => "http://data.gov/updated",
          :junk    => "This is an extra param (junk)"
        }
      end
    
      use "attempted PUT source with :fake_id with invalid param"
    end
      
    context "#{role} API key : put /:fake_id with correct params" do
      before do
        put "/#{@fake_id}", {
          :api_key => primary_api_key_for(role),
          :url     => "http://data.gov/updated"
        }
      end
      
      use "attempted PUT source with :fake_id with correct params"
    end
      
    context "#{role} API key : put /:id with protected param" do
      before do
        put "/#{@id}", {
          :api_key    => primary_api_key_for(role),
          :url        => "http://data.gov/updated",
          :updated_at => Time.now.to_json
        }
      end
      
      use "attempted PUT source with :id with protected param"
    end
      
    context "#{role} API key : put /:id with invalid param" do
      before do
        put "/#{@id}", {
          :api_key => primary_api_key_for(role),
          :url     => "http://data.gov/updated",
          :junk    => "This is an extra param (junk)"
        }
      end
      
      use "attempted PUT source with :id with invalid param"
    end
      
    context "#{role} API key : put /:id with invalid url" do
      before do
        put "/#{@id}", {
          :api_key => primary_api_key_for(role),
          :url     => "https://secret.com/13"
        }
      end
      
      use "attempted PUT source with :id with invalid url"
    end
      
    context "#{role} API key : put /:id without params" do
      before do
        put "/#{@id}", {
          :api_key => primary_api_key_for(role),
        }
      end
      
      use "attempted PUT source with :id without params"
    end
      
    context "#{role} API key : put /:id with correct param" do
      before do
        put "/#{@id}", {
          :api_key => primary_api_key_for(role),
          :url     => "http://data.gov/updated"
        }
      end
      
      use "successful PUT to sources"
    end
    
    context "#{role} API key : post / with 1 custom field" do
      before do
        put "/#{@id}", {
          :api_key                 => primary_api_key_for(role),
          :url                     => "http://data.gov/updated",
          "custom[0][label]"       => "custom 1",
          "custom[0][description]" => "description 1",
          "custom[0][type]"        => "string",
          "custom[0][value]"       => "HR-57"
        }
      end
    
      use "successful PUT to sources"
    
      test "custom field should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 1",      source.custom["0"]["label"]
        assert_equal "description 1", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end
    end
    
    context "#{role} API key : post / adding 2 custom fields" do
      before do
        put "/#{@id}", {
          :api_key                 => primary_api_key_for(role),
          :url                     => "http://data.gov/updated",
          "custom[0][label]"       => "custom 1",
          "custom[0][description]" => "description 1",
          "custom[0][type]"        => "string",
          "custom[0][value]"       => "HR-57",
          "custom[1][label]"       => "custom 2",
          "custom[1][description]" => "description 2",
          "custom[1][type]"        => "integer",
          "custom[1][value]"       => "100"
        }
      end
    
      use "successful PUT to sources"
    
      test "should have 2 custom fields" do
        source = Source.find_by_id(@id)
        assert_equal 2, source.custom.length
        assert_include "0", source.custom
        assert_include "1", source.custom
      end
      
      test "custom field 0 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 1",      source.custom["0"]["label"]
        assert_equal "description 1", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end
    
      test "custom field 1 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 2",      source.custom["1"]["label"]
        assert_equal "description 2", source.custom["1"]["description"]
        assert_equal "integer",       source.custom["1"]["type"]
        assert_equal "100",           source.custom["1"]["value"]
      end
    end
    
    context "#{role} API key : post / changing 1 custom field" do
      before do
        create_source_with_three_custom_fields
        put "/#{@id}", {
          :api_key           => primary_api_key_for(role),
          "custom[1][value]" => "333"
        }
      end
    
      test "should have 3 custom fields" do
        source = Source.find_by_id(@id)
        assert_equal 3, source.custom.length
        3.times do |n|
          assert_include n.to_s, source.custom
        end
      end
    
      test "custom field 0 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 0",      source.custom["0"]["label"]
        assert_equal "description 0", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end
    
      test "custom field 1 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 1",      source.custom["1"]["label"]
        assert_equal "description 1", source.custom["1"]["description"]
        assert_equal "integer",       source.custom["1"]["type"]
        assert_equal "333",           source.custom["1"]["value"]
      end
    
      test "custom field 2 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 2",      source.custom["2"]["label"]
        assert_equal "description 2", source.custom["2"]["description"]
        assert_equal "date",          source.custom["2"]["type"]
        assert_equal "2009-09-28",    source.custom["2"]["value"]
      end
    end
  
    context "#{role} API key : post / removing a custom field" do
      before do
        create_source_with_three_custom_fields
        put "/#{@id}", {
          :api_key    => primary_api_key_for(role),
          "custom[1]" => nil,
        }
      end
      
      test "should have 3 custom fields" do
        source = Source.find_by_id(@id)
        assert_equal 3, source.custom.length
        assert_include "0", source.custom
        assert_include "1", source.custom
        assert_include "2", source.custom
      end
    
      test "custom field 0 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 0",      source.custom["0"]["label"]
        assert_equal "description 0", source.custom["0"]["description"]
        assert_equal "string",        source.custom["0"]["type"]
        assert_equal "HR-57",         source.custom["0"]["value"]
      end

      test "custom field 1 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal nil, source.custom[1]
      end
    
      test "custom field 2 should be correct in database" do
        source = Source.find_by_id(@id)
        assert_equal "custom 2",      source.custom["2"]["label"]
        assert_equal "description 2", source.custom["2"]["description"]
        assert_equal "date",          source.custom["2"]["type"]
        assert_equal "2009-09-28",    source.custom["2"]["value"]
      end
    end
  end
end

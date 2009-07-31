module InformationAboutApi
  
  def self.included(mod)
    mod.should_give Status200
    
    mod.test "body has name" do
      assert_equal "National Data Catalog API", parsed_response_body["name"]
    end

    mod.test "body has correct creator" do
      assert_equal "The Sunlight Labs", parsed_response_body["creator"]
    end

    mod.test "body has correct version" do
      assert_equal "0.10", parsed_response_body["version"]
    end
    
    mod.test "body has list of resources" do
      expected = [
        {
          "sources" => "http://localhost:4567/sources"
        }
      ]
      assert_equal expected, parsed_response_body["resources"]
    end

    mod.test "body contains only the expected keys" do
      assert_equal [], parsed_response_body.keys - %w(
        authentication_note
        authentication_status
        creator
        name
        resources
        version
      )
    end
  end
  
end

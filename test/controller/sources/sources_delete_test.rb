require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    source = Source.create(
      :title => "The Original Data Source",
      :url   => "http://data.gov/original"
    )
    @id = source.id
    @source_count = Source.count
    @fake_id = get_fake_mongo_object_id
  end

  shared "attempted DELETE source with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
  end

  shared "successful DELETE source with :id" do
    use "return 200 Ok"
    use "decremented source count"

    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end

    test "source should be deleted in database" do
      assert_equal nil, Source.find_by_id(@id)
    end
  end

  shared "attempted double DELETE source with :id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented source count"

    test "should be deleted in database" do
      assert_equal nil, Source.find_by_id(@id)
    end
  end

  context "anonymous : delete /" do
    before do
      delete "/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged source count"
  end

  context "incorrect API key : delete /" do
    before do
      delete "/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged source count"
  end

  context "normal API key : delete /" do
    before do
      delete "/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end


  context "curator API key : delete /:fake_id" do
    before do
      delete "/#{@fake_id}", :api_key => @curator_user.primary_api_key
    end
    
    use "attempted DELETE source with :fake_id"
  end

  context "admin API key : delete /:fake_id" do
    before do
      delete "/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "attempted DELETE source with :fake_id"
  end

  context "curator API key : delete /:id" do
    before do
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "successful DELETE source with :id"
  end
  
  context "admin API key : delete /:id" do
    before do
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "successful DELETE source with :id"
  end

  context "admin API key : double delete /users" do
    before do
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
      delete "/#{@id}", :api_key => @curator_user.primary_api_key
    end
    
    use "attempted double DELETE source with :id"
  end

  context "admin API key : double delete /users" do
    before do
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "attempted double DELETE source with :id"
  end

end

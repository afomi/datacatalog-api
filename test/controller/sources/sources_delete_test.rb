require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesDeleteControllerTest < RequestTestCase

  before do
    source = Source.create :url => "http://dc.gov/busses"
    @id = source.id
    @source_count = Source.count
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : delete /sources" do
    before do
      delete "/sources/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged source count"
  end

  context "incorrect API key : delete /sources" do
    before do
      delete "/sources/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged source count"
  end

  context "normal API key : delete /sources" do
    before do
      delete "/sources/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /sources/:fake_id" do
    before do
      delete "/sources/#{@fake_id}", :api_key => @admin_user.primary_api_key
    end

    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
  end

  # - - - - - - - - - -

  context "admin API key : delete /sources/:id" do
    before do
      delete "/sources/#{@id}", :api_key => @admin_user.primary_api_key
    end

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

  context "admin API key : double delete /users" do
    before do
      delete "/sources/#{@id}", :api_key => @admin_user.primary_api_key
      delete "/sources/#{@id}", :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented source count"
  
    test "source should be deleted in database" do
      assert_equal nil, Source.find_by_id(@id)
    end
  end

end

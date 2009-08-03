require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class DeleteSourcesControllerTest < RequestTestCase

  def setup_for_deletion
    source = Source.create :url => "http://dc.gov/busses"
    @id = source.id
    @source_count = Source.count
  end

  context "anonymous user : delete /sources" do
    before :all do
      setup_for_deletion
      delete "/sources/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged source count"
  end

  context "incorrect user : delete /sources" do
    before :all do
      setup_for_deletion
      delete "/sources/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged source count"
  end

  context "unconfirmed user : delete /sources" do
    before :all do
      setup_for_deletion
      delete "/sources/#{@id}", :api_key => @unconfirmed_user.api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end

  context "confirmed user : delete /sources" do
    before :all do
      setup_for_deletion
      delete "/sources/#{@id}", :api_key => @confirmed_user.api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end

  context "admin user : delete /sources" do
    before :all do
      setup_for_deletion
      delete "/sources/#{@id}", :api_key => @admin_user.api_key
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

  context "admin user : double delete /users" do
    before :all do
      setup_for_deletion
      delete "/sources/#{@id}", :api_key => @admin_user.api_key
      delete "/sources/#{@id}", :api_key => @admin_user.api_key
    end
    
    use "return 404 Not Found"
    use "decremented source count"
    use "return an empty response body"
  
    test "source should be deleted in database" do
      assert_equal nil, Source.find_by_id(@id)
    end
  end

end

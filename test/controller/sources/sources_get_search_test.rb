require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Sources end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of sources where url is source #3'" do
    test "body should have 1 top level elements" do
      assert_equal 1, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal 'http://data.gov/sources/3', element["url"]
        assert_shared_attributes element
      end
    end
  end

  # - - - - - - - - - -

  context_ "3 sources" do
    before do
      3.times do |n|
        assert Source.create(
          :url => "http://data.gov/sources/#{n+1}"
        ).valid?
      end
    end

    # - - - - - - - - - -

    context "anonymous : get / where url is source #3" do
      before do
        get "/",
          :url     => "http://data.gov/sources/3"
      end
    
      use "return 401 because the API key is missing"
    end

    context "missing API key : get / where url is source #3" do
      before do
        get "/",
          :url     => "http://data.gov/sources/3",
          :api_key => "does_not_exist_in_database"
      end
    
      use "return 401 because the API key is invalid"
    end

    # - - - - - - - - - -

    context "normal API key : get / where url is source #3" do
      before do
        get "/",
          :url     => "http://data.gov/sources/3",
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of sources where url is source #3'"
    end

    context "admin API key : get / where url is source #3" do
      before do
        get "/",
          :url     => "http://data.gov/sources/3",
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of sources where url is source #3'"
    end
  end

end

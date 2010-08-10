require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ResourcesTest < RequestTestCase

  def app
    DataCatalog::Resources
  end

  def resources_from_response_body
    assert_include "members", parsed_response_body
    members = parsed_response_body["members"]
    members.map { |r| r["href"] }
  end

  shared "return a list of anonymous resources" do
    test "should list anonymous resources" do
      resources = resources_from_response_body
      assert_include "/"          , resources
      assert_include "/checkup"   , resources
      assert_include "/resources" , resources
    end
  end

  shared "return a list of basic resources" do
    test "should list basic resources" do
      resources = resources_from_response_body
      assert_include "/"              , resources
      assert_include "/catalogs"      , resources
      assert_include "/categories"    , resources
      assert_include "/checkup"       , resources
      assert_include "/comments"      , resources
      assert_include "/documents"     , resources
      assert_include "/downloads"     , resources
      assert_include "/favorites"     , resources
      assert_include "/importers"     , resources
      assert_include "/imports"       , resources
      assert_include "/notes"         , resources
      assert_include "/organizations" , resources
      assert_include "/ratings"       , resources
      assert_include "/source_groups" , resources
      assert_include "/sources"       , resources
      assert_include "/tags"          , resources
      assert_include "/users"         , resources
    end
  end

  shared "return a list of curator resources" do
    test "should list curator resources" do
      resources = resources_from_response_body
      assert_include "/broken_links"  , resources
      assert_include "/reports"       , resources
    end
  end

  context "anonymous : get /" do
    before do
      get '/'
    end

    use "return 200 OK"
    use "return a list of anonymous resources"
  end

  context "incorrect API key : get /" do
    before do
      get '/', :api_key => BAD_API_KEY
    end

    use "return 401 because the API key is invalid"
  end

  context "normal API key : get /" do
    before do
      get '/', :api_key => @normal_user.primary_api_key
    end

    use "return 200 OK"
    use "return a list of anonymous resources"
    use "return a list of basic resources"
  end

  context "curator API key : get /" do
    before do
      get '/', :api_key => @curator_user.primary_api_key
    end

    use "return 200 OK"
    use "return a list of anonymous resources"
    use "return a list of basic resources"
    use "return a list of curator resources"
  end

  context "admin API key : get /" do
    before do
      get '/', :api_key => @admin_user.primary_api_key
    end

    use "return 200 OK"
    use "return a list of anonymous resources"
    use "return a list of basic resources"
    use "return a list of curator resources"
  end

end

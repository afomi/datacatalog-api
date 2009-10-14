require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Organizations end

  # - - - - - - - - - -
  
  shared "successful GET of 0 organizations" do
    use "return 200 Ok"
    use "return an empty list response body"
  end
  
  shared "successful GET of 3 organizations" do
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end
    
    test "body should have correct name" do
      actual = (0 ... 3).map { |n| parsed_response_body[n]["name"] }
      3.times { |n| assert_include "Organization #{n}", actual }
    end
    
    test "each element should have correct attributes" do
      parsed_response_body.each do |element|
        assert_include "source_id", element
        assert_include "user_id", element
        assert_include "needs_curation", element
        assert_include "created_at", element
        assert_include "updated_at", element
        assert_include "id", element
        assert_not_include "_id", element
      end
    end
  end
  
  # - - - - - - - - - -
  
  context "anonymous : get /" do
    before do
      get "/"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /" do
    before do
      get "/", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end

  # - - - - - - - - - -

  context_ "0 organizations" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of 0 organizations"
    end

    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of 0 organizations"
    end
  end

  # - - - - - - - - - -

  context_ "3 organizations" do
    before do
      3.times do |n|
        Organization.create(
          :name      => "Organization #{n}",
          :user_id   => get_fake_mongo_object_id,
          :source_id => get_fake_mongo_object_id
        )
      end
    end
    
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "successful GET of 3 organizations"
    end
  
    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end

      use "successful GET of 3 organizations"
    end
  end

end

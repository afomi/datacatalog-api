require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  # - - - - - - - - - -
  
  shared "successful GET of 0 sources" do
    use "return 200 Ok"
    use "return an empty response body"
  end
  
  shared "successful GET of 3 sources" do
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "body should have correct text" do
      actual = (0 ... 3).map { |n| parsed_response_body[n]["url"] }
      3.times { |n| assert_include "http://data.gov/sources/#{n}", actual }
    end
  
    3.times do |n|
      test "element #{n} should have created_at" do
        assert_include "created_at", parsed_response_body[n]
      end
        
      test "element #{n} should have updated_at" do
        assert_include "updated_at", parsed_response_body[n]
      end
      
      test "element #{n} should have id" do
        assert_include "id", parsed_response_body[n]
      end
        
      test "element #{n} should not have _id" do
        assert_not_include "_id", parsed_response_body[n]
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

  context "normal API key : get / : 0" do
    before do
      get "/", :api_key => @normal_user.primary_api_key
    end
    
    use "successful GET of 0 sources"
  end

  context "admin API key : get / : 0" do
    before do
      get "/", :api_key => @admin_user.primary_api_key
    end
    
    use "successful GET of 0 sources"
  end

  # - - - - - - - - - -

  context "normal API key : get / : 3" do
    before do
      3.times do |n|
        Source.create :url => "http://data.gov/sources/#{n}"
      end
      get "/", :api_key => @normal_user.primary_api_key
    end

    use "successful GET of 3 sources"
  end
  
  context "admin API key : get / : 3" do
    before do
      3.times do |n|
        Source.create :url => "http://data.gov/sources/#{n}"
      end
      get "/", :api_key => @admin_user.primary_api_key
    end

    use "successful GET of 3 sources"
  end

end

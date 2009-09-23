require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

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

    test "each element should have correct attributes" do
      parsed_response_body.each do |element|
        assert_include "created_at", element
        assert_include "updated_at", element
        assert_include "id", element
        assert_not_include "_id", element
      end
    end
  end
  
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

  context_ "0 sources" do
    %w(normal curator admin).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
        end

        use "successful GET of 0 sources"
      end
    end
  end

  context_ "3 sources" do
    before do
      3.times do |n|
        Source.create(
          :title => "Source #{n}", 
          :url   => "http://data.gov/sources/#{n}"
        )
      end
    end

    %w(normal curator admin).each do |role|
      context "#{role} API key : get /" do
        before do
          get "/", :api_key => primary_api_key_for(role)
        end

        use "successful GET of 3 sources"
      end
    end
  end

end

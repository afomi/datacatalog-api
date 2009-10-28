require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CategoriesGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Categories end

  context "0 categories" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "return 200 Ok"
      use "return an empty list response body"
    end
  end
  
  context "3 categories" do
    before do
      @categories = 3.times.map do |n|
        create_category(:name => "Category #{n}")
      end
    end
    
    after do
      @categories.each { |x| x.destroy }
    end
  
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
  
      test "body should have 3 top level elements" do
        assert_equal 3, parsed_response_body.length
      end

      test "body should have correct text" do
        actual = (0 ... 3).map { |n| parsed_response_body[n]["name"] }
        3.times { |n| assert_include "Category #{n}", actual }
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
  end

end

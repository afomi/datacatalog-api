require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CategoriesGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Categories end
  
  shared "successful GET of categories where text is 'Category 3'" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "Category 3", element["name"]
        assert_equal @user_id, element["user_id"]
      end
    end
  end

  context "6 categories" do
    before do
      @categories = 6.times.map do |n|
        create_category(:name => "Category #{(n % 3) + 1}")
      end
    end
    
    after do
      @categories.each { |x| x.destroy }
    end

    context "normal API key : get / where text is 'Category 3'" do
      before do
        get "/", {
          :api_key => @normal_user.primary_api_key,
          :filter  => %(name="Category 3")
        }
      end
    
      use "successful GET of categories where text is 'Category 3'"
    end
  end

end

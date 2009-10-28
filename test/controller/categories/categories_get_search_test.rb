require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CategoriesGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Categories end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of categories where text is 'Category 3'" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "Category 3", element["name"]
        assert_equal @user_id, element["user_id"]
        assert_shared_attributes(element)
      end
    end
  end

  # - - - - - - - - - -

  context "6 categories" do
    before do
      6.times do |n|
        k = (n % 3) + 1
        assert Category.create(
          :name => "Category #{k}"
        ).valid?
      end
    end

    # - - - - - - - - - -

    context "anonymous : get / where text is 'Category 3'" do
      before do
        get "/", {
          :name => "Category 3"
        }
      end
    
      use "return 401 because the API key is missing"
    end
    
    context "incorrect API key : get / where text is 'Category 3'" do
      before do
        get "/", {
          :api_key => "does_not_exist_in_database",
          :name    => "Category 3",
        }
      end
    
      use "return 401 because the API key is invalid"
    end

    # - - - - - - - - - -

    context "normal API key : get / where text is 'Category 3'" do
      before do
        get "/", {
          :api_key => @normal_user.primary_api_key,
          :name    => "Category 3",
        }
      end
    
      use "successful GET of categories where text is 'Category 3'"
    end

    context "admin API key : get / where text is 'Category 3'" do
      before do
        get "/", {
          :api_key => @admin_user.primary_api_key,
          :name    => "Category 3",
        }
      end
    
      use "successful GET of categories where text is 'Category 3'"
    end
  end

end

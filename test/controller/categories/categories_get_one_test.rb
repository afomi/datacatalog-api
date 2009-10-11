require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CategoriesGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Categories end

  before do
    category = Category.create(
      :name => "Category A"
    )
    @id = category.id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  shared "attempted GET category with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
  end

  shared "successful GET category with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "Category A", parsed_response_body["name"]
    end
  end

  # - - - - - - - - - -

  context_ "get /:id" do
    context "anonymous" do
      before do
        get "/#{@id}"
      end
    
      use "return 401 because the API key is missing"
    end
  
    context "incorrect API key" do
      before do
        get "/#{@id}", :api_key => "does_not_exist_in_database"
      end
    
      use "return 401 because the API key is invalid"
    end
  end

  %w(normal curator admin).each do |role|
    context "#{role} API key : get /:fake_id" do
      before do
        get "/#{@fake_id}", :api_key => primary_api_key_for(role)
      end

      use "attempted GET category with :fake_id"
    end

    context "#{role} API key : get /:id" do
      before do
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET category with :id"
    end

    context "#{role} API key : 2 categorizations : get /:id" do
      before do
        @sources = [
          create_source({
            :title => "Macroeconomic Indicators 2008",
            :url   => "http://www.macro.gov/indicators/2008"
          }),
          create_source({
            :title => "Macroeconomic Indicators 2009",
            :url   => "http://www.macro.gov/indicators/2009"
          }),
        ]
        @sources.each do |source|
          c = create_categorization(
            :category_id => @id,
            :source_id   => source.id
          )
        end
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end
    
      use "successful GET category with :id"
      
      test "body should have correct source_ids" do
        actual = parsed_response_body["source_ids"]
        expected = @sources.map(&:id)
        assert_equal expected, actual
      end
    end
  end

end

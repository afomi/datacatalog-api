require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategorizationsGetFilterTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  shared "successful GET of categorizations where text is 'Category 3'" do
    test "body should have 2 top level elements" do
      assert_equal 2, @members.length
    end

    test "each element should be correct" do
      @members.each do |element|
        assert_equal "Category 3", element["name"]
        assert_equal @user_id, element["user_id"]
      end
    end
  end

  # Probably shouldn't be able to create multiple Categorizations
  # where for the same Source/Category combo
  context "6 categorizations" do
    before do
      @source = create_source
      @category = create_category(:name => "Category 1")
      @categorizations = 6.times.map do |n|
        create_categorizations(:source_id => @source.id, :category_id => @category.id)
      end
    end

    after do
      @categorizations.each { |x| x.destroy }
    end

    context "normal API key : get / where text is 'Category 3'" do
      before do
        get "/", {
          :api_key => @normal_user.primary_api_key,
          :filter  => %(name="Category 3")
        }
        @members = parsed_response_body['members']
      end

      use "successful GET of categorizations where text is 'Category 3'"
    end
  end

end

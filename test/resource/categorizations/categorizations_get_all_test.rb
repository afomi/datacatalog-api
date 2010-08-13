require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategorizationsGetAllTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  context "0 categorizations" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 categorizations" do
    before do
      @user = create_user
      @source = create_source
      @category = create_category(:name => "Category-1")
      @categorizations = 3.times.map do |n|
        create_categorizations(:source_id => @source.id, :category_id => @category.id)
      end
    end

    after do
      @categorizations.each { |x| x.destroy }
    end

    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct text" do
        actual = (0 ... 3).map { |n| @members[n]["name"] }
        3.times { |n| assert_include "Category #{n}", actual }
      end

      test "each element should have correct attributes" do
        @members.each do |element|
          assert_include "created_at", element
          assert_include "updated_at", element
          assert_include "id", element
          assert_not_include "_id", element
        end
      end
    end
  end

end

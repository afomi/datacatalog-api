require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourceGroupsGetAllTest < RequestTestCase

  def app; DataCatalog::SourceGroups end

  context "0 source groups" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 source groups" do
    before do
      @source_groups = 3.times.map do |n|
        create_source_group({
          :title => "Source Group #{n}",
        })
      end
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
        actual = (0 ... 3).map { |n| @members[n]["title"] }
        3.times { |n| assert_include "Source Group #{n}", actual }
      end
    end
  end

end

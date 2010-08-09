require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class BrokenLinksGetAllTest < RequestTestCase

  def app; DataCatalog::BrokenLinks end

  context "0 broken_links" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @curator_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 broken_links" do
    before do
      @organization = create_organization
      @broken_links = 3.times.map do |n|
        create_broken_link({
          :field           => "field_#{n}",
          :organization_id => @organization.id,
        })
      end
    end

    after do
      @broken_links.each { |x| x.destroy }
      @organization.destroy
    end

    context "normal API key : get /" do
      before do
        get "/", :api_key => @curator_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct text" do
        actual = (0 ... 3).map { |n| @members[n]["field"] }
        3.times { |n| assert_include "field_#{n}", actual }
      end
    end
  end

end

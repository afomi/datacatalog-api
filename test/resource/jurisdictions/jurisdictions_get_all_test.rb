require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class JurisdictionsGetAllTest < RequestTestCase

  def app; DataCatalog::Jurisdictions end

  context "0 jurisdictions" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 jurisdictions" do
    before do
      @jurisdictions = 3.times.map do |i|
        create_jurisdiction(
          :name      => "Jurisdiction #{i}",
          :user_id   => @normal_user.id
        )
      end
    end
    
    after do
      @jurisdictions.each { |x| x.destroy }
    end
    
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct name" do
        actual = (0 ... 3).map { |n| @members[n]["name"] }
        3.times { |n| assert_include "Jurisdiction #{n}", actual }
      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TagsGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Tags end

  context "0 tags" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "return 200 Ok"
      use "return an empty list response body"
    end
  end

  context "3 tags" do
    before do
      @tags = 3.times.map do |n|
        create_tag(:text => "Tag #{n}")
      end
    end
    
    after do
      @tags.each { |x| x.destroy }
    end
    
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      test "body should have 3 top level elements" do
        assert_equal 3, parsed_response_body.length
      end

      test "body should have correct text" do
        actual = (0 ... 3).map { |n| parsed_response_body[n]["text"] }
        3.times { |n| assert_include "Tag #{n}", actual }
      end
    end
  end

end

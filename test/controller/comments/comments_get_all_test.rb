require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  context "0 comments" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "return 200 Ok"
      use "return an empty list response body"
    end
  end

  context "3 comments" do
    before do
      @comments = 3.times.map do |n|
        create_comment(
          :text      => "Comment #{n}",
          :user_id   => get_fake_mongo_object_id,
          :source_id => get_fake_mongo_object_id
        )
      end
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
        3.times { |n| assert_include "Comment #{n}", actual }
      end
    end
  end

end

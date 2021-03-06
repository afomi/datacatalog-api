require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CommentsGetAllTest < RequestTestCase

  def app; DataCatalog::Comments end

  context "0 comments" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 comments" do
    before do
      @user = create_user
      @source = create_source
      @comments = 3.times.map do |n|
        create_comment(
          :text      => "Comment #{n}",
          :user_id   => @user.id,
          :source_id => @source.id
        )
      end
    end

    after do
      @comments.each { |x| x.destroy }
      @source.destroy
      @user.destroy
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
        actual = (0 ... 3).map { |n| @members[n]["text"] }
        3.times { |n| assert_include "Comment #{n}", actual }
      end
    end
  end

end

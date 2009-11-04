require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CommentsGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Comments end
  
  context "6 comments" do
    before do
      @user = create_user
      @sources = 3.times.map do |i|
        create_source
      end
      @comments = 6.times.map do |i|
        k = i % 3
        create_comment(
          :text      => "comment #{k}",
          :user_id   => @user.id,
          :source_id => @sources[k].id
        )
      end
    end
    
    after do
      @comments.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
      @user.destroy
    end

    context "normal API key : get / where text is 'comment 1'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => %(text="comment 1")
      end
    
      test "body should have 2 top level elements" do
        assert_equal 2, parsed_response_body.length
      end

      test "each element should be correct" do
        parsed_response_body.each do |element|
          assert_equal "comment 1", element["text"]
          assert_equal @user.id, element["user_id"]
          assert_equal @sources[1].id, element["source_id"]
        end
      end
    end

  end

end

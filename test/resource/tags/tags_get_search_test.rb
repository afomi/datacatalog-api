require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TagsGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Tags end
  
  shared "successful GET of tags where text is 'tag 1'" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "tag 1", element["text"]
        assert_equal @user_id, element["user_id"]
        assert_equal "#{@source_base}1", element["source_id"]
      end
    end
  end

  context "6 tags" do
    before do
      @user_id       = "4aa677bb25b7e70733000001"
      @source_base   = "200077d325b7e7073300000"
      @tags = 6.times.map do |n|
        k = (n % 3) + 1
        create_tag(
          :text      => "tag #{k}",
          :user_id   => @user_id,
          :source_id => "#{@source_base}#{k}"
        )
      end
    end
    
    after do
      @tags.each { |x| x.destroy }
    end

    context "normal API key : get / where text is 'tag 1'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => "text='tag 1'"
      end
    
      use "successful GET of tags where text is 'tag 1'"
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Comments end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of comments where text is 'comment 2'" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "comment 2", element["text"]
        assert_equal @user_id, element["user_id"]
        assert_equal "#{@source_base}2", element["source_id"]
        assert_shared_attributes element
      end
    end
  end

  # - - - - - - - - - -

  context_ "6 comments" do
    before do
      @user_id     = "4aa677bb25b7e70733000001"
      @source_base = "200077d325b7e7073300000"
      6.times do |n|
        k = (n % 3) + 1
        assert Comment.create(
          :text      => "comment #{k}",
          :user_id   => @user_id,
          :source_id => "#{@source_base}#{k}"
        ).valid?
      end
    end

    # - - - - - - - - - -

    context "anonymous : get / where text is 'comment 2'" do
      before do
        get "/",
          :text    => "comment 2"
      end
    
      use "return 401 because the API key is missing"
    end
    
    context "incorrect API key : get / where text is 'comment 2'" do
      before do
        get "/",
          :text    => "comment 2",
          :api_key => "does_not_exist_in_database"
      end
    
      use "return 401 because the API key is invalid"
    end

    # - - - - - - - - - -

    context "normal API key : get / where text is 'comment 2'" do
      before do
        get "/",
          :text    => "comment 2",
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of comments where text is 'comment 2'"
    end

    context "admin API key : get / where text is 'comment 2'" do
      before do
        get "/",
          :text    => "comment 2",
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of comments where text is 'comment 2'"
    end
  end

end

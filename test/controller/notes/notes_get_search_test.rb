require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Notes end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of notes where text is 'Note 2'" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal 'Note 2', element["text"]
        assert_equal @normal_user.id, element["user_id"]
        assert_equal @sources[2].id, element["source_id"]
        assert_shared_attributes element
      end
    end
  end

  # - - - - - - - - - -

  context_ "6 notes" do
    before :all do
      @sources = (0 ... 3).map { |n| create_source }
      6.times do |n|
        k = n % 3
        create_note(
          :text      => "Note #{k}",
          :user_id   => @normal_user.id,
          :source_id => @sources[k].id
        )
      end
    end

    # - - - - - - - - - -

    context "anonymous : get / where text is 'Note 2'" do
      before do
        get "/",
          :text    => "Note 2"
      end
    
      use "return 401 because the API key is missing"
    end
    
    context "incorrect API key : get / where text is 'Note 2'" do
      before do
        get "/",
          :text    => 'Note 2',
          :api_key => "does_not_exist_in_database"
      end
    
      use "return 401 because the API key is invalid"
    end
    
    # - - - - - - - - - -

    context "normal API key : get / where text is 'Note 2'" do
      before do
        get "/",
          :text    => 'Note 2',
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of notes where text is 'Note 2'"
    end

    context "admin API key : get / where text is 'Note 2'" do
      before do
        get "/",
          :text    => 'Note 2',
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of notes where text is 'Note 2'"
    end
  end

end

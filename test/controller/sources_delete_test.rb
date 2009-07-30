require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class DeleteSourcesControllerTest < RequestTestCase

  context "delete /sources/_id" do

    before :all do
      reset_sources
      post '/sources', :url => "http://delete-me.com"
      @id = parsed_response_body["_id"]
      delete "/sources/#{@id}"
    end

    test "body should have updated_at" do
      assert_equal @id, parsed_response_body["_id"]
    end
  end

end

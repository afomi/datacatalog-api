require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class NotesGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Notes end

  context "0 notes" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
      
      use "return 200 Ok"
      use "return an empty list response body"
    end
  end

  context "3 notes" do
    before do
      @sources = 3.times.map do |n|
        create_source(
          :title   => "Source #{n}",
          :user_id => @normal_user.id
        )
      end
      @notes = 3.times.map do |n|
        create_note(
          :text      => "Note #{n}",
          :source_id => @sources[n].id
        )
      end
    end
    
    after do
      @notes.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
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
        3.times { |n| assert_include "Note #{n}", actual }
      end
    end
  end
  
end

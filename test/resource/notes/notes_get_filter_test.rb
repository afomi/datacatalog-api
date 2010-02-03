require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class NotesGetFilterTest < RequestTestCase

  def app; DataCatalog::Notes end
  
  context "6 notes" do
    before do
      @sources = (0 ... 3).map { |n| create_source }
      @notes = 6.times.map do |n|
        k = n % 3
        create_note(
          :text      => "Note #{k}",
          :user_id   => @normal_user.id,
          :source_id => @sources[k].id
        )
      end
    end
    
    after do
      @notes.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
    end

    context "normal API key : get / where text is 'Note 2'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => "text:'Note 2'"
        @members = parsed_response_body['members']
      end
      
      use "return 200 OK"
    
      test "body should have 2 top level elements" do
        assert_equal 2, @members.length
      end
      
      test "each element should be correct" do
        @members.each do |element|
          assert_equal 'Note 2', element["text"]
          assert_equal @normal_user.id.to_s, element["user_id"]
          assert_equal @sources[2].id.to_s, element["source_id"]
        end
      end
    end
  end

end

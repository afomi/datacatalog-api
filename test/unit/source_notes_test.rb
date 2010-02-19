require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceNotesUnitTest < ModelTestCase
  
  context "source with no notes" do
    before do
      @source = create_source
    end
    
    test "#notes should return []" do
      assert_equal [], @source.notes
    end
  end
  
  context "source with 3 notes" do
    before do
      @user = create_normal_user
      @source = create_source
      @notes = []
      3.times do |n|
        @notes << create_note(
          :text      => "Note #{n}",
          :source_id => @source.id,
          :user_id   => @user.id
        )
      end
    end
    
    after do
      @notes.each { |x| x.destroy }
      @source.destroy
      @user.destroy
    end
    
    test "#notes should return 3 objects" do
      assert_equal 3, @source.notes.length
    end
    
    3.times do |n|
      test "#notes should include value of #{n}" do
        assert_include "Note #{n}", @source.notes.map(&:text)
      end
      
      test "finding id for #{n} should succeed" do
        assert_equal @notes[n], @source.notes.first(:_id => @notes[n].id)
      end
    end
    
    test "find with fake_id should not raise exception" do
      assert_equal nil, @source.notes.first(:_id => get_fake_mongo_object_id)
    end

    test "find! with fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @source.notes.find!(get_fake_mongo_object_id)
      end
    end
  end

end

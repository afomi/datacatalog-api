require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class UserNotesUnitTest < ModelTestCase
  
  context "user with no notes" do
    before do
      @user = create_user
    end
    
    test "#notes should return []" do
      assert_equal [], @user.notes
    end
  end
  
  context "user with 3 notes" do
    before do
      @user = create_user
      @sources = 3.times.map do |i|
        create_source
      end
      @notes = 3.times.map do |i|
        create_note(
          :text      => "Note #{i}",
          :source_id => @sources[i].id,
          :user_id   => @user.id
        )
      end
    end
    
    after do
      @notes.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
      @user.destroy
    end
    
    test "#notes should return 3 objects" do
      assert_equal 3, @user.notes.length
    end
    
    test "finding id should succeed" do
      3.times do |n|
        assert_equal @notes[n], @user.notes.first(:_id => @notes[n].id)
      end
    end
    
    test "find with fake_id should not raise exception" do
      assert_equal nil, @user.notes.first(:_id => get_fake_mongo_object_id)
    end

    test "find! with fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @user.notes.find!(get_fake_mongo_object_id)
      end
    end
  end

end

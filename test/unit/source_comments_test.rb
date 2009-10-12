require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceCommentsUnitTest < ModelTestCase
  
  context "source with no comments" do
  
    before do
      @source = create_source
    end
    
    test "#comments should return []" do
      assert_equal [], @source.comments
    end
  
  end
  
  context "source with 3 comments" do
  
    before do
      @user = create_normal_user
      @source = create_source
      @comments = []
      3.times do |n|
        @comments << create_comment(
          :text      => "Comment #{n}",
          :source_id => @source.id,
          :user_id   => @user.id
        )
      end
    end
    
    test "#comments should return 3 objects" do
      assert_equal 3, @source.comments.length
    end
    
    3.times do |n|
      test "#comments should include value of #{n}" do
        assert_include "Comment #{n}", @source.comments.map(&:text)
      end
      
      test "finding id for #{n} should succeed" do
        assert_equal @comments[n], @source.comments.find(@comments[n].id)
      end
    end
    
    # This behavior probably will be changing soon in MongoMapper
    #
    # * find will return nil and find! will raise exception
    # * wherever find is called it should behave the same whether
    #   associations or plain old documents
    test "finding fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @source.comments.find(get_fake_mongo_object_id)
      end
    end

  end

end

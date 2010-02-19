require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class SourceDocumentsUnitTest < ModelTestCase
  
  context "source with no documents" do
    before do
      @source = create_source
    end
    
    after do
      @source.destroy
    end
    
    test "#documents should return []" do
      assert_equal [], @source.documents
    end
  end
  
  context "source with 3 documents" do
  
    before :all do
      @user = create_normal_user
      @source = create_source
      @documents = []
      3.times do |n|
        @documents << create_document(
          :text      => "Document #{n}",
          :source_id => @source.id,
          :user_id   => @user.id
        )
      end
    end
    
    after :all do
      @documents.each { |x| x.destroy }
      @source.destroy
      @user.destroy
    end
    
    test "#documents should return 3 objects" do
      assert_equal 3, @source.documents.length
    end
    
    3.times do |n|
      test "#documents should include value of #{n}" do
        assert_include "Document #{n}", @source.documents.map(&:text)
      end
      
      test "finding id for #{n} should succeed" do
        assert_equal @documents[n], @source.documents.first(:_id => @documents[n].id)
      end
    end
    
    test "find with fake_id should not raise exception" do
      assert_equal nil, @source.documents.first(:_id => get_fake_mongo_object_id)
    end

    test "find! with fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @source.documents.find!(get_fake_mongo_object_id)
      end
    end
  end

end

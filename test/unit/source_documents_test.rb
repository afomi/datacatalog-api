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
  
    before do
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
    
    after do
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
        assert_equal @documents[n], @source.documents.find(@documents[n].id)
      end
    end
    
    # This behavior probably will be changing soon in MongoMapper
    #
    # * find will return nil and find! will raise exception
    # * wherever find is called it should behave the same whether
    #   associations or plain old documents
    test "finding fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @source.documents.find(get_fake_mongo_object_id)
      end
    end

  end

end

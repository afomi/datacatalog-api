require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class SourcesGetFilterTest < RequestTestCase

  def app; DataCatalog::Sources end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of sources where url is source #3'" do
    test "body should have 1 top level elements" do
      assert_equal 1, @members.length
    end

    test "each element should be correct" do
      @members.each do |element|
        assert_equal 'http://data.gov/sources/3', element["url"]
        assert_shared_attributes element
      end
    end
  end

  context "3 sources" do
    before do
      @sources = 3.times.map do |n|
        create_source(
          :title => "Source #{n + 1}", 
          :url   => "http://data.gov/sources/#{n + 1}"
        )
      end
    end
    
    after do
      @sources.each { |x| x.destroy }
    end
    
    %w(normal).each do |role|
      context "#{role} API key : get / where url is source #3" do
        before do
          get "/",
            :filter  => "url=http://data.gov/sources/3",
            :api_key => primary_api_key_for(role)
          @members = parsed_response_body['members']
        end

        use "successful GET of sources where url is source #3'"
      end
    end
  end

end

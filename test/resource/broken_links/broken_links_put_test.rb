require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class BrokenLinksPutTest < RequestTestCase

  def app; DataCatalog::BrokenLinks end

  before do
    @source = create_source
    @broken_link = create_broken_link({
      :source_id       => @source.id,
      :field           => "url",
      :destination_url => "http://broken.gov/stuff/88",
      :status          => 404,
    })
    @broken_link_count = BrokenLink.count
  end

  after do
    @broken_link.destroy
    @source.destroy
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@broken_link.id}", {
        :api_key => @admin_user.primary_api_key,
        :junk    => "WTF"
      }
    end

    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end

  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@broken_link.id}", {
        :api_key         => @admin_user.primary_api_key,
        :destination_url => "http://broken.gov/stuff/41",
      }
    end
  
    use "return 200 Ok"
    use "unchanged broken_link count"
  
    test "text should be updated in database" do
      broken_link = BrokenLink.find_by_id!(@broken_link.id)
      assert_equal "http://broken.gov/stuff/41", broken_link.destination_url
    end
  end

end

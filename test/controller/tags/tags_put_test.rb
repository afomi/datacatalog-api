require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class TagsPutControllerTest < RequestTestCase

  def app; DataCatalog::Tags end

  before :all do
    @tag = Tag.create({
      :text => "Original Tag"
    })
    @id = @tag.id
    @fake_id = get_fake_mongo_object_id
    @tag_count = Tag.count
  end

  # - - - - - - - - - -

  shared "unchanged tag text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Tag", @tag.text
    end
  end

  shared "attempted PUT tag with :fake_id with protected param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
    use "unchanged tag text in database"
  end

  shared "attempted PUT tag with :fake_id with invalid param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
    use "unchanged tag text in database"
  end

  shared "attempted PUT tag with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged tag count"
    use "unchanged tag text in database"
  end

  shared "attempted PUT tag with :id with protected param" do
    use "return 400 Bad Request"
    use "unchanged tag count"
    use "unchanged tag text in database"
    use "return errors hash saying updated_at is invalid"
  end

  shared "attempted PUT tag with :id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged tag count"
    use "unchanged tag text in database"
    use "return errors hash saying junk is invalid"
  end

  shared "successful PUT tag with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged tag count"

    test "text should be updated in database" do
      tag = Tag.find_by_id(@id)
      assert_equal "New Tag", tag.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /" do
    before do
      put "/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged tag count"
  end

  context "incorrect API key : put /" do
    before do
      put "/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged tag count"
  end

  context "normal API key : put /" do
    before do
      put "/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged tag count"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Tag",
        :created_at => Time.now.to_json
      }
    end
    
    use "attempted PUT tag with :fake_id with protected param"
  end

  context "admin API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Tag",
        :created_at => Time.now.to_json
      }
    end
  
    use "attempted PUT tag with :fake_id with protected param"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Tag",
        :junk    => "This is an extra param (junk)"
      }
    end
    
    use "attempted PUT tag with :fake_id with invalid param"
  end
  
  context "admin API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT tag with :fake_id with invalid param"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Tag"
      }
    end
    
    use "attempted PUT tag with :fake_id with correct params"
  end
    
  context "admin API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag"
      }
    end
  
    use "attempted PUT tag with :fake_id with correct params"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Tag",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT tag with :id with protected param"
  end

  context "admin API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Tag",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT tag with :id with protected param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Tag",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT tag with :id with invalid param"
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT tag with :id with invalid param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Tag"
      }
    end
    
    use "successful PUT tag with :id"
  end
  
  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Tag"
      }
    end
    
    use "successful PUT tag with :id"
  end

end

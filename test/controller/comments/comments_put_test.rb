require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CommentsPutControllerTest < RequestTestCase

  def app; DataCatalog::Comments end

  before :all do
    @comment = Comment.create(
      :text      => "Original Comment",
      :user_id   => get_fake_mongo_object_id,
      :source_id => get_fake_mongo_object_id
    )
    @id = @comment.id
    @fake_id = get_fake_mongo_object_id
    @comment_count = Comment.count
  end

  # - - - - - - - - - -

  shared "unchanged comment text in database" do
    test "text should be unchanged in database" do
      assert_equal "Original Comment", @comment.text
    end
  end

  shared "attempted PUT comment with :fake_id with protected param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged comment count"
    use "unchanged comment text in database"
  end

  shared "attempted PUT comment with :fake_id with invalid param" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged comment count"
    use "unchanged comment text in database"
  end

  shared "attempted PUT comment with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged comment count"
    use "unchanged comment text in database"
  end

  shared "attempted PUT comment with :id with protected param" do
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "unchanged comment text in database"
    use "return errors hash saying updated_at is invalid"
  end

  shared "attempted PUT comment with :id with invalid param" do
    use "return 400 Bad Request"
    use "unchanged comment count"
    use "unchanged comment text in database"
    use "return errors hash saying junk is invalid"
  end

  shared "attempted PUT comment with :id without params" do
    use "return 400 Bad Request"
    use "unchanged comment count"
    
    test "body should say 'no_params_to_save'" do
      assert_include "no_params_to_save", parsed_response_body["errors"]
    end
  
    test "return help_text saying params are needed" do
      assert_include "cannot save without parameters", parsed_response_body["help_text"]
    end
  end

  shared "successful PUT comment with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged comment count"

    test "text should be updated in database" do
      comment = Comment.find_by_id(@id)
      assert_equal "New Comment", comment.text
    end
  end

  # - - - - - - - - - -

  context "anonymous : put /" do
    before do
      put "/#{@id}"
    end
  
    use "return 401 because the API key is missing"
    use "unchanged comment count"
  end

  context "incorrect API key : put /" do
    before do
      put "/#{@id}", :api_key => "does_not_exist_in_database"
    end
  
    use "return 401 because the API key is invalid"
    use "unchanged comment count"
  end

  context "normal API key : put /" do
    before do
      put "/#{@id}", :api_key => @normal_user.primary_api_key
    end
  
    use "return 401 because the API key is unauthorized"
    use "unchanged comment count"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Comment",
        :created_at => Time.now.to_json
      }
    end
    
    use "attempted PUT comment with :fake_id with protected param"
  end

  context "admin API key : put /:fake_id with protected param" do
    before do
      put "/#{@fake_id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Comment",
        :created_at => Time.now.to_json
      }
    end
  
    use "attempted PUT comment with :fake_id with protected param"
  end

  # - - - - - - - - - -

  context "curator API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Comment",
        :junk    => "This is an extra param (junk)"
      }
    end
    
    use "attempted PUT comment with :fake_id with invalid param"
  end
  
  context "admin API key : put /:fake_id with invalid param" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT comment with :fake_id with invalid param"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Comment"
      }
    end
    
    use "attempted PUT comment with :fake_id with correct params"
  end
    
  context "admin API key : put /:fake_id with correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment"
      }
    end
  
    use "attempted PUT comment with :fake_id with correct params"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @curator_user.primary_api_key,
        :text       => "New Comment",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT comment with :id with protected param"
  end

  context "admin API key : put /:id with protected param" do
    before do
      put "/#{@id}", {
        :api_key    => @admin_user.primary_api_key,
        :text       => "New Comment",
        :updated_at => Time.now.to_json
      }
    end
    
    use "attempted PUT comment with :id with protected param"
  end
  
  # - - - - - - - - - -
  
  context "curator API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Comment",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT comment with :id with invalid param"
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment",
        :junk    => "This is an extra param (junk)"
      }
    end
  
    use "attempted PUT comment with :id with invalid param"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key
      }
    end

    use "attempted PUT comment with :id without params"
  end

  context "admin API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key
      }
    end

    use "attempted PUT comment with :id without params"
  end

  # - - - - - - - - - -
  
  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :text    => "New Comment"
      }
    end
    
    use "successful PUT comment with :id"
  end
  
  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Comment"
      }
    end
    
    use "successful PUT comment with :id"
  end

end

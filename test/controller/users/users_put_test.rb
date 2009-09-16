require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersPutControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before :all do
    @user = User.create({
      :name    => "Original Guy",
      :email   => "original.guy@email.com",
    })
    @user.add_api_key!({ :key_type => "primary" })
    @id = @user.id
    @fake_id = get_fake_mongo_object_id
    @user_count = User.count
  end
  
  # - - - - - - - - - -

  shared "unchanged name in database" do
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @user.name
    end
  end
  
  shared "unchanged email in database" do
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @user.email
    end
  end

  shared "attempted PUT user with :fake_id with protected param 'admin'" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
    use "unchanged name in database"
    use "unchanged email in database"
  end

  shared "attempted PUT user with :fake_id with invalid param 'junk'" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
    use "unchanged name in database"
    use "unchanged email in database"
  end

  shared "attempted PUT user with :id with protected param 'admin'" do
    use "return 400 Bad Request"
    use "unchanged user count"
    use "unchanged name in database"
    use "unchanged email in database"
    use "return errors hash saying admin is invalid"
  end
  
  shared "attempted PUT user with :id with invalid param 'junk'" do
    use "return 400 Bad Request"
    use "unchanged user count"
    use "unchanged name in database"
    use "unchanged email in database"
    use "return errors hash saying junk is invalid"
  end
  
  shared "attempted PUT user with :fake_id with correct params" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged user count"
    use "unchanged name in database"
    use "unchanged email in database"
  end

  shared "attempted PUT user with :id without params" do
    use "return 400 Bad Request"
    use "unchanged user count"
    
    test "body should say 'no_params_to_save'" do
      assert_include "no_params_to_save", parsed_response_body["errors"]
    end
  
    test "return help_text saying params are needed" do
      assert_include "cannot save without parameters", parsed_response_body["help_text"]
    end
  end

  shared "successful PUT user with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
    use "unchanged user count"
    
    test "name should be updated in database" do
      user = User.find_by_id(@id)
      assert_equal "New Guy", user.name
    end
      
    test "email should be updated in database" do
      user = User.find_by_id(@id)
      assert_equal "new.guy@email.com", user.email
    end

    test "body should have API key, 40 characters long" do
      assert_equal 40, parsed_response_body["primary_api_key"].length
    end
    
    test "body should have API key different from admin key" do
      assert_not_equal @admin_user.primary_api_key, parsed_response_body["primary_api_key"]
    end
  end

  # - - - - - - - - - -
  
  context "anonymous : put /:id" do
    before do
      put "/#{@id}"
    end

    use "return 401 because the API key is missing"
    use "unchanged user count"
  end
  
  context "incorrect API key : put /:id" do
    before do
      put "/#{@id}", :api_key => "does_not_exist_in_database"
    end

    use "return 401 because the API key is invalid"
    use "unchanged user count"
  end
  
  context "normal API key : put /:id" do
    before do
      put "/#{@id}", :api_key => @normal_user.primary_api_key
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id with protected param 'admin'" do
    before do
      put "/#{@fake_id}", {
        :api_key   => @curator_user.primary_api_key,
        :name      => "New Guy",
        :email     => "new.guy@email.com",
        :admin     => true
      }
    end
    
    use "attempted PUT user with :fake_id with protected param 'admin'"
  end
  
  context "admin API key : put /:fake_id with protected param 'admin'" do
    before do
      put "/#{@fake_id}", {
        :api_key   => @admin_user.primary_api_key,
        :name      => "New Guy",
        :email     => "new.guy@email.com",
        :admin     => true
      }
    end
    
    use "attempted PUT user with :fake_id with protected param 'admin'"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id with invalid param 'junk'" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :junk    => "This is an extra parameter (junk)"
      }
    end
    
    use "attempted PUT user with :fake_id with invalid param 'junk'"
  end

  context "admin API key : put /:fake_id with invalid param 'junk'" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
        :junk    => "This is an extra parameter (junk)"
      }
    end

    use "attempted PUT user with :fake_id with invalid param 'junk'"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:id with protected param 'admin'" do
    before do
      put "/#{@id}", {
        :api_key   => @curator_user.primary_api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :admin     => true
      }
    end
    
    use "attempted PUT user with :id with protected param 'admin'"
  end
  
  context "admin API key : put /:id with protected param 'admin'" do
    before do
      put "/#{@id}", {
        :api_key   => @admin_user.primary_api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
        :admin     => true
      }
    end
    
    use "attempted PUT user with :id with protected param 'admin'"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id with invalid param 'junk'" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :junk    => "This is an extra parameter (junk)"
      }
    end
    
    use "attempted PUT user with :id with invalid param 'junk'"
  end
  
  context "admin API key : put /:id with invalid param 'junk'" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
        :junk    => "This is an extra parameter (junk)"
      }
    end

    use "attempted PUT user with :id with invalid param 'junk'"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:fake_id : create : correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @curator_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end
    
    use "attempted PUT user with :fake_id with correct params"
  end
  
  context "admin API key : put /:fake_id : create : correct params" do
    before do
      put "/#{@fake_id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end

    use "attempted PUT user with :fake_id with correct params"
  end

  # - - - - - - - - - -

  context "curator API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key
      }
    end

    use "attempted PUT user with :id without params"
  end

  context "admin API key : put /:id without params" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key
      }
    end

    use "attempted PUT user with :id without params"
  end
  
  # - - - - - - - - - -

  context "curator API key : put /:id with correct params" do
    before do
      put "/#{@id}", {
        :api_key => @curator_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end
    
    use "successful PUT user with :id"
  end

  context "admin API key : put /:id with correct params" do
    before do
      put "/#{@id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end

    use "successful PUT user with :id"
  end

end

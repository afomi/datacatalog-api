require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  # - - - - - - - - - -
  
  shared "correct attributes for each user" do
    test "each element should have correct attributes" do
      parsed_response_body.each do |element|
        assert_include "primary_api_key", element
        assert_equal 40, element["primary_api_key"].length
        assert_include "created_at", element
        assert_include "updated_at", element
        assert_include "id", element
        assert_not_include "_id", element
      end
    end
  end
  
  shared "successful GET of 0 added users" do
    use "return 200 Ok"
    
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "elements should have correct names" do
      names = (0 ... 3).map { |n| parsed_response_body[n]["name"] }
      assert_include "Normal User", names
      assert_include "Curator User", names
      assert_include "Admin User", names
    end

    test "elements should have correct emails" do
      emails = (0 ... 3).map { |n| parsed_response_body[n]["email"] }
      assert_include "normal.user@inter.net", emails
      assert_include "curator.user@inter.net", emails
      assert_include "admin.user@inter.net", emails
    end
    
    test "element should have different API keys" do
      keys = (0 ... 3).map { |n| parsed_response_body[n]["primary_api_key"] }
      assert_equal 3, keys.uniq.length
    end
    
    use "correct attributes for each user"
  end
  
  shared "successful GET of 3 added users" do
    test "body should have 6 top level elements" do
      assert_equal 6, parsed_response_body.length
    end

    test "body should have correct text" do
      actual = (3 ... 6).map { |n| parsed_response_body[n]["text"] }
      (3 ... 6).each { |n| assert_include "User #{n}", actual }
    end

    use "correct attributes for each user"
  end
  
  # - - - - - - - - - -
  
  context "anonymous : get /" do
    before do
      get "/"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /" do
    before do
      get "/", :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end

  # - - - - - - - - - -

  context_ "0 added users" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of 0 added users"
    end
  
    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of 0 added users"
    end
  end
  
  # - - - - - - - - - -
  
  context_ "3 added users" do
    before do
      3.times do |n|
        @user = User.new(
          :text => "User #{n + 3}"
        )
        @keys = [
          ApiKey.new({
            :api_key  => @user.generate_api_key,
            :key_type => "primary",
            :purpose  => "The primary key"
          })
        ]
        @user.api_keys = @keys
        @user.save!
      end
    end
  
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
  
      use "successful GET of 3 added users"
    end

    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end
  
      use "successful GET of 3 added users"
    end
  end

end

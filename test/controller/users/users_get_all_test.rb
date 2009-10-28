require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetAllControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  shared "show public attributes for each user" do
    test "each element should show public attributes" do
      parsed_response_body.each do |element|
        assert_include "created_at", element
        assert_include "updated_at", element
        assert_include "id", element
        assert_not_include "_id", element
      end
    end
  end
  
  shared "hide private attributes for other users" do
    test "each element should hide private attributes" do
      parsed_response_body.each do |element|
        if element["id"] != @normal_user.id
          assert_not_include "primary_api_key", element
          assert_not_include "application_api_keys", element
          assert_not_include "valet_api_keys", element
          assert_not_include "admin", element
          assert_not_include "curator", element
          assert_not_include "email", element
        end
      end
    end
  end

  shared "show private attributes for each user" do
    test "each element should show private attributes" do
      parsed_response_body.each do |element|
        assert_include "primary_api_key", element
        assert_include "application_api_keys", element
        assert_include "valet_api_keys", element
        assert_include "admin", element
        assert_include "curator", element
        assert_include "email", element
      end
    end
  end

  shared "show all 3 users" do
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

    use "show public attributes for each user"
  end

  shared "show all 6 users" do
    use "return 200 Ok"

    test "body should have 6 top level elements" do
      assert_equal 6, parsed_response_body.length
    end

    test "body should have correct names" do
      actual = parsed_response_body.map { |element| element["name"] }
      (3 ... 6).each { |n| assert_include "User #{n}", actual }
    end
  end
  
  shared "have 3 unique API keys" do
    test "elements should have different API keys" do
      keys = (0 ... 3).map { |n| parsed_response_body[n]["primary_api_key"] }
      assert_equal 3, keys.uniq.length
    end
  end

  shared "have 6 unique API keys" do
    test "elements should have different API keys" do
      keys = (0 ... 6).map { |n| parsed_response_body[n]["primary_api_key"] }
      assert_equal 6, keys.uniq.length
    end
  end
  
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

  context "0 added users" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
    
      use "show all 3 users"
      use "hide private attributes for other users"
    end
  
    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end

      use "show all 3 users"
      use "have 3 unique API keys"
      use "show private attributes for each user"

      test "elements should have correct emails" do
        emails = (0 ... 3).map { |n| parsed_response_body[n]["email"] }
        assert_include "normal.user@inter.net", emails
        assert_include "curator.user@inter.net", emails
        assert_include "admin.user@inter.net", emails
      end
    end
  end
  
  context "3 added users" do
    before :all do
      3.times do |n|
        create_user_with_primary_key(
          :name  => "User #{n + 3}",
          :email => "user-#{n + 3}@email.com"
        )
      end
    end
  
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end
      
      use "show all 6 users"
      use "hide private attributes for other users"
    end
  
    context "admin API key : get /" do
      before do
        get "/", :api_key => @admin_user.primary_api_key
      end
  
      use "show all 6 users"
      use "have 6 unique API keys"
      use "show private attributes for each user"

      test "body should have correct emails" do
        actual = parsed_response_body.map { |element| element["email"] }
        (3 ... 6).each { |n| assert_include "user-#{n}@email.com", actual }
      end
    end
  end

end

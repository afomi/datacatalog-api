require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersPostTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user_count = User.count
  end

  shared "attempted POST user with protected param 'admin'" do
    use "return 400 Bad Request"
    use "return errors hash saying admin is invalid"
  end

  shared "attempted POST user with invalid param 'junk'" do
    use "return 400 Bad Request"
    use "return errors hash saying junk is invalid"
  end

  shared "successful POST user" do
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented user count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_user_uri = "http://localhost:4567/users/" + parsed_response_body["id"]
      assert_equal new_user_uri, last_response.headers["Location"]
    end

    test "body should have correct name" do
      assert_equal "John Doe", parsed_response_body["name"]
    end

    test "body should have correct email" do
      assert_equal "john.doe@email.com", parsed_response_body["email"]
    end

    test "body should have primary API key, 40 characters long" do
      assert_equal 40, parsed_response_body["primary_api_key"].length
    end

    test "body should have API key different from admin key" do
      assert_not_equal @admin_user.primary_api_key,
        parsed_response_body["primary_api_key"]
    end

    test "name should be correct in database" do
      user = User.find_by_id!(parsed_response_body["id"])
      assert_equal "John Doe", user.name
    end

    test "email should be correct in database" do
      user = User.find_by_id!(parsed_response_body["id"])
      assert_equal "john.doe@email.com", user.email
    end
  end

  context "owner API key : post / with correct params" do
    before do
      post '/', {
        :api_key => @normal_user.primary_api_key,
        :name    => "John Doe",
        :email   => "john.doe@email.com",
      }
    end

    # A normal user cannot create a new user account
    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end

  context "curator API key : post / with correct params" do
    before do
      post '/', {
        :api_key   => @curator_user.primary_api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
      }
    end

    # A curator user cannot create a new user account
    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end

  context "admin API key : post / with correct params" do
    before do
      post '/', {
        :api_key   => @admin_user.primary_api_key,
        :name      => "John Doe",
        :email     => "john.doe@email.com",
      }
    end

    use "successful POST user"
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Users end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of users where name is 'User 2'" do
    test "body should have 1 top level elements" do
      assert_equal 1, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "User 2", element["name"]
        assert_shared_attributes element
      end
    end
  end

  # - - - - - - - - - -

  context "3 added users" do
    before do
      3.times do |n|
        create_user_with_primary_key(
          :name    => "User #{n}",
          :email   => "user-#{n}@email.com"
        )
      end
    end

    # - - - - - - - - - -

    context "anonymous : get / where name is 'User 2'" do
      before do
        get "/",
          :name    => 'User 2'
      end
    
      use "return 401 because the API key is missing"
    end

    context "incorrect API key : get / where name is 'User 2'" do
      before do
        get "/",
          :name    => 'User 2',
          :api_key => "does_not_exist_in_database"
      end
    
      use "return 401 because the API key is invalid"
    end
    
    # - - - - - - - - - -

    context "normal API key : get / where name is 'User 2'" do
      before do
        get "/",
          :name    => 'User 2',
          :api_key => @normal_user.primary_api_key
      end
      
      use "successful GET of users where name is 'User 2'"

      test "each element should not expose sensitive values" do
        parsed_response_body.each do |element|
          assert_not_include "email", parsed_response_body
          assert_not_include "curator", parsed_response_body
          assert_not_include "admin", parsed_response_body
        end
      end
    end

    context "admin API key : get / where name is 'User 2'" do
      before do
        get "/",
          :name    => 'User 2',
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of users where name is 'User 2'"

      test "each element should expose all values" do
        parsed_response_body.each do |element|
          assert_equal "user-2@email.com", element["email"]
          assert_include "curator", element
          assert_include "admin", element
        end
      end
    end
  end

end

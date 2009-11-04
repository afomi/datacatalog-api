require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Users end
  
  shared "successful GET of users where name is 'User 2'" do
    test "body should have 1 top level elements" do
      assert_equal 1, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "User 2", element["name"]
      end
    end
  end

  context "3 added users" do
    before do
      3.times do |n|
        create_user_with_primary_key(
          :name    => "User #{n}",
          :email   => "user-#{n}@email.com"
        )
      end
    end

    context "normal API key : get / where name is 'User 2'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => "name='User 2'"
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
          :api_key => @admin_user.primary_api_key,
          :filter  => "name='User 2'"
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

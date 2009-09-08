require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Users end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of users where name is 'User 4'" do
    test "body should have 1 top level elements" do
      assert_equal 1, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "User 4", element["name"]
        assert_equal "user-4@email.com", element["email"]
        assert_shared_attributes element
      end
    end
  end

  # - - - - - - - - - -

  context_ "3 added users" do
    before do
      3.times do |n|
        user = User.new(
          :name    => "User #{n + 3}",
          :email   => "user-#{n + 3}@email.com",
          :curator => false,
          :admin   => false
        )
        keys = [
          ApiKey.new({
            :api_key  => user.generate_api_key,
            :key_type => "primary",
            :purpose  => "The primary key"
          })
        ]
        user.api_keys = keys
        user.save!
      end
    end

    # - - - - - - - - - -

    context "anonymous : get / where name is 'User 4'" do
      before do
        get "/",
          :name    => "User 4"
      end
    
      use "return 401 because the API key is missing"
    end

    context "incorrect API key : get / where name is 'User 4'" do
      before do
        get "/",
          :name    => "User 4",
          :api_key => "does_not_exist_in_database"
      end
    
      use "return 401 because the API key is invalid"
    end
    
    # - - - - - - - - - -

    context "normal API key : get / where name is 'User 4'" do
      before do
        get "/",
          :name    => "User 4",
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of users where name is 'User 4'"
    end

    context "admin API key : get / where name is 'User 4'" do
      before do
        get "/",
          :name    => "User 4",
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of users where name is 'User 4'"
    end
  end

end

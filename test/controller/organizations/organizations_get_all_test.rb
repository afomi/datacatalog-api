require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class OrganizationsGetAllControllerTest < RequestTestCase
  
  context "anonymous user : get /organizations" do
    before do
      get '/organizations'
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect user : get /organizations" do
    before do
      get '/organizations', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end

  # - - - - - - - - - -

  context "normal user : get /organizations : 0" do
    before do
      get '/organizations', :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return an empty response body"
  end

  context "admin user : get /organizations : 0" do
    before do
      get '/organizations', :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"
    use "return an empty response body"
  end

  # - - - - - - - - - -
  
  shared "shared tests for successfully getting 3 organizations" do
    test "body should have 3 top level elements" do
      assert_equal 3, parsed_response_body.length
    end

    test "body should have correct text" do
      actual = (0 ... 3).map { |n| parsed_response_body[n]["text"] }
      3.times { |n| assert_include "Organization #{n}", actual }
    end
  
    3.times do |n|
      test "element #{n} should have created_at" do
        assert_include "created_at", parsed_response_body[n]
      end
        
      test "element #{n} should have updated_at" do
        assert_include "updated_at", parsed_response_body[n]
      end
      
      test "element #{n} should have id" do
        assert_include "id", parsed_response_body[n]
      end
        
      test "element #{n} should not have _id" do
        assert_not_include "_id", parsed_response_body[n]
      end
    end
  end

  context "normal user : get /organizations : 3" do
    before do
      3.times { |n| Organization.create :text => "Organization #{n}" }
      get '/organizations', :api_key => @normal_user.primary_api_key
    end
    
    use "shared tests for successfully getting 3 organizations"
  end
  
  context "admin user : get /organizations : 3" do
    before do
      3.times { |n| Organization.create :text => "Organization #{n}" }
      get '/organizations', :api_key => @admin_user.primary_api_key
    end
  
    use "shared tests for successfully getting 3 organizations"
  end

end

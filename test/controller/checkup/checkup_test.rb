require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class CheckupTest < RequestTestCase
  
  def app
    DataCatalog::Checkup
  end

  # - - - - - - - - - -

  shared "anonymous" do
    test "should indicate anonymous credentials" do
      assert_include "anonymous", parsed_response_body
      assert_equal true, parsed_response_body["anonymous"]
    end
  end

  shared "not anonymous" do
    test "should indicate non-anonymous credentials" do
      assert_include "anonymous", parsed_response_body
      assert_equal false, parsed_response_body["anonymous"]
    end
  end

  shared "valid API key" do
    test "should indicate valid API key" do
      assert_include "valid_api_key", parsed_response_body
      assert_equal true, parsed_response_body["valid_api_key"]
    end
  end

  shared "invalid API key" do
    test "should indicate invalid API key" do
      assert_include "valid_api_key", parsed_response_body
      assert_equal false, parsed_response_body["valid_api_key"]
    end
  end

  # - - - - - - - - - -
  
  context "anonymous : get /" do
    before do
      get '/'
    end

    use "return 200 OK"
    use "anonymous"
    
    test "should not have a user" do
      assert_not_include "user", parsed_response_body
    end
  end
  
  context "incorrect API key : get /" do
    before do
      get '/', :api_key => "does_not_exist_in_database"
    end
  
    use "return 200 OK"
    use "invalid API key"
  end
  
  context "normal API key : get /" do
    before do
      get '/', :api_key => @normal_user.primary_api_key
    end
    
    use "return 200 OK"
    use "not anonymous"
    use "valid API key"

    test "should have correct user href" do
      expected = {
        "href" => "/users/#{@normal_user.id}",
        "id"   => @normal_user.id
      }
      assert_equal expected, parsed_response_body["user"]
    end
  end
  
  context "curator API key : get /" do
    before do
      get '/', :api_key => @curator_user.primary_api_key
    end
    
    use "return 200 OK"
    use "not anonymous"
    use "valid API key"
  
    test "should indicate curator permissions" do
      assert_include "curator", parsed_response_body
      assert_equal true, parsed_response_body["curator"]
    end

    test "should have correct user href" do
      expected = {
        "href" => "/users/#{@curator_user.id}",
        "id"   => @curator_user.id
      }
      assert_equal expected, parsed_response_body["user"]
    end
  end
  
  context "admin API key : get /" do
    before do
      get '/', :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 OK"
    use "not anonymous"
    use "valid API key"
  
    test "should indicate admin permissions" do
      assert_include "admin", parsed_response_body
      assert_equal true, parsed_response_body["admin"]
    end

    test "should have correct user href" do
      expected = {
        "href" => "/users/#{@admin_user.id}",
        "id"   => @admin_user.id
      }
      assert_equal expected, parsed_response_body["user"]
    end
  end

end

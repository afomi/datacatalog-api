require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# The root action(s) provide basic information about the API.
#
# Passing an API key as a parameter is not allowed. Why not?
#
# * There is nothing about 'get /' that involves authentication. Checking
#   authentication wouldn't serve any purpose. Not checking means that
#   this action can be very simple.
#
# * On the other hand, accepting an API key parameter would imply that the
#   web service does some sort of verification. Doing that verification
#   would make the action more complicated and would also slow it down
#   (since we would need to lookup the API key.)

class RootControllerTest < RequestTestCase
  
  context "anonymous user : get /" do
    before :all do
      get '/'
    end
    should_give InformationAboutApi
  end
  
  context "incorrect user : get /" do
    doing {
      get '/', :api_key => "does_not_exist_in_database"
    }.should_give ApiKeyNotAllowed
  end

  context "unconfirmed user : get /" do
    doing {
      get '/', :api_key => @unconfirmed_user.api_key
    }.should_give ApiKeyNotAllowed
  end

  context "confirmed user : get /" do
    doing {
      get '/', :api_key => @confirmed_user.api_key
    }.should_give ApiKeyNotAllowed
  end

  context "admin user : get /" do
    doing {
      get '/', :api_key => @admin_user.api_key
    }.should_give ApiKeyNotAllowed
  end

end

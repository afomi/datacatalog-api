require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UserUnitTest < ModelTestCase
  
  context "creating a User" do
    before :all do
      @user = User.create({
        :email => "data.mangler@usa.gov"
      })
    end
    
    test "should " do
      assert_equal "data.mangler@usa.gov", @user.email
    end
  end
  
end

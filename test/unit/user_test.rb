require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UserUnitTest < ModelTestCase
  
  context "creating a User" do
    before :all do
      @user = User.create({
        :email => "data.mangler@usa.gov"
      })
    end
    
    test "should save email" do
      assert_equal "data.mangler@usa.gov", @user.email
    end
  end
  
  # TODO: Add validation testing

  context "creating 2 users" do
    before :all do
      @user_1 = User.new({
        :name  => "Data Mangler",
        :email => "data.mangler@usa.gov"
      })
      @user_1.generate_api_key!

      @user_2 = User.new({
        :name  => "Data Mangler",
        :email => "data.mangler@usa.gov"
      })
      @user_2.generate_api_key
    end
    
    test "API keys should be unique" do
      assert_not_equal @user_1.api_key, @user_2.api_key
    end
  end
  
  context "create 10,000 users with API keys" do
    before :all do
      @api_keys = []
      10_000.times do |x|
        user = User.new({
          :name  => "Joe Smith",
          :email => "joe.smith@inter.net"
        })
        @api_keys[x] = user.generate_api_key
      end
    end
    
    test "all API keys should be unique" do
      hash = {}
      @api_keys.each do |api_key|
        if hash[api_key]
          flunk "A duplicate API key was generated: #{api_key}"
        end 
        hash[api_key] = true
      end
      assert true
    end
  end
  
end

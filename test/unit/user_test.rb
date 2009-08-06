require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class UserUnitTest < ModelTestCase

  def create_user
    user = User.create({
      :name  => "Data Mangler",
      :email => "data.mangler@usa.gov"
    })
  end

  def create_user_with_api_key
    user = create_user
    user.add_api_key!
    user
  end
  
  # - - - - - - - - - -

  shared "well formed primary API key" do
    test "primary API key should be 40 characters long" do
      assert_equal 40, @user.primary_api_key.length
    end
  end

  # - - - - - - - - - -
  
  context "creating a user" do
    before do
      @user = create_user
    end
    
    test "should save email" do
      assert_equal "data.mangler@usa.gov", @user.email
    end
  end

  # - - - - - - - - - -
  
  context "creating a user with an API key" do
    before do
      @user = create_user_with_api_key
    end
    
    use "well formed primary API key"
  end

  context "creating a user with 2 API keys" do
    before do
      @user = create_user_with_api_key
      @user.add_api_key!
    end

    use "well formed primary API key"
    
    test "should have 2 API keys" do
      assert_equal 2, @user.api_keys.length
    end
  end
  
  context "creating 2 users with API keys" do
    before do
      @users = [
        create_user_with_api_key,
        create_user_with_api_key
      ]
    end
    
    test "API keys should be unique" do
      assert_not_equal @users[0].primary_api_key, @users[1].primary_api_key
    end
  end

  context "create 10,000 API keys" do
    before do
      user = User.new({
        :name  => "In Memory Only",
        :email => "in.memory.only@usa.gov"
      })
      @api_keys = []
      10_000.times do |x|
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

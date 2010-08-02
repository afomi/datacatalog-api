require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersPutTest < RequestTestCase

  def app; DataCatalog::Users end

  before :all do
    @user = create_user(
      :name    => "Original Guy",
      :email   => "original.guy@email.com"
    )
    @user.add_api_key!({ :key_type => "primary" })
    @user_count = User.count
  end

  after :all do
    @user.destroy
  end

  shared "unchanged name in database" do
    test "name should be unchanged in database" do
      assert_equal "Original Guy", @user.name
    end
  end

  shared "unchanged email in database" do
    test "email should be unchanged in database" do
      assert_equal "original.guy@email.com", @user.email
    end
  end

  shared "successful PUT user with :id" do
    use "return 200 Ok"
    use "unchanged user count"

    test "name should be updated in database" do
      user = User.find_by_id!(@user.id)
      assert_equal "New Guy", user.name
    end

    test "email should be updated in database" do
      user = User.find_by_id!(@user.id)
      assert_equal "new.guy@email.com", user.email
    end

    test "body should have API key, 40 characters long" do
      assert_equal 40, parsed_response_body["primary_api_key"].length
    end

    test "body should have API key different from admin key" do
      assert_not_equal @admin_user.primary_api_key, parsed_response_body["primary_api_key"]
    end
  end

  context "owner API key : put /:id with correct params" do
    before do
      put "/#{@user.id}", {
        :api_key => @user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end

    use "successful PUT user with :id"
  end

  context "curator API key : put /:id with correct params" do
    before do
      put "/#{@user.id}", {
        :api_key => @curator_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end

    use "return 401 because the API key is unauthorized"
    use "unchanged user count"
  end

  context "admin API key : put /:id with correct params" do
    before do
      put "/#{@user.id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Guy",
        :email   => "new.guy@email.com",
      }
    end

    use "successful PUT user with :id"
  end

end

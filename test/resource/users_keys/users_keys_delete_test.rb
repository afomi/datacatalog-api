require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersKeysDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user(
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    )

    @keys = [
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "primary",
        :purpose  => "The primary key"
      }),
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "application",
        :purpose  => "Key for application #1"
      }),
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "application",
        :purpose  => "Key for application #2"
      }),
      ApiKey.new({
        :api_key  => @user.generate_api_key,
        :key_type => "valet",
        :purpose  => "A valet key"
      })
    ]
    @user.api_keys = @keys
    @user.save!
    @api_key_count = @user.api_keys.length
  end
  
  after do
    @user.destroy
  end

  shared "return error about attempt to delete primary API key" do
    test "body should explain that you cannot delete a primary API key" do
      assert_include "errors", parsed_response_body
      assert_include "cannot_delete_primary_api_key", parsed_response_body["errors"]
    end
  end
  
  shared "API key deleted from database" do
    test "API key should be deleted in database" do
      raise "@n must be defined" unless @n
      user = User.find_by_id!(@user.id)
      api_key = user.api_keys.detect { |x| x.id == @keys[@n].id }
      assert_equal nil, api_key
    end
  end

  [0].each do |n|
    context "Primary API key" do
      context "owner API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @user.api_keys[n].api_key
        end
  
        use "return 409 Conflict"
        use "return error about attempt to delete primary API key"
        use "unchanged api_key count"
      end
  
      context "admin API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
        end
      
        use "return 409 Conflict"
        use "return error about attempt to delete primary API key"
        use "unchanged api_key count"
      end
    end
  end

  (1 ... 3).each do |n|
    context "API key #{n}" do
      context "owner API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @user.api_keys[n].api_key
          @n = n
        end
  
        use "return 204 No Content"
        use "decremented api_key count"
        use "API key deleted from database"
      end

      context "admin API key : delete /:id/keys/:id" do
        before do
          delete "/#{@user.id}/keys/#{@keys[n].id}",
            :api_key => @admin_user.primary_api_key
          @n = n
        end
          
        use "return 204 No Content"
        use "decremented api_key count"
        use "API key deleted from database"
      end
    end
  end
  
end

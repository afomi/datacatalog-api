require File.expand_path(File.dirname(__FILE__) + '/users_keys')

module DataCatalog

  class Users < Base
  
    resource "users" do
      model User

      permission_to_view :basic
      permission_to_modify :basic

      read_only :api_keys
      read_only :admin
      read_only :created_at
      read_only :updated_at

      callback :after_create do
        @document.add_api_key!({ :key_type => "primary" })
      end

      nested_resource UsersKeys, :association => :api_keys
    end

    def self.permit_modify?(current_user, user)
      current_user.admin || current_user == user
    end

  end

end

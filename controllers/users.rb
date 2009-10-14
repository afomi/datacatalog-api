require File.expand_path(File.dirname(__FILE__) + '/users_keys')

module DataCatalog

  class Users < Base
  
    resource "users" do
      model User

      permission_to_view :basic
      permission_to_modify :basic

      read_only :api_keys
      read_only :admin
      read_only :creator_api_key
      read_only :created_at
      read_only :updated_at

      callback :after_create do
        @document.add_api_key!({ :key_type => "primary" })
      end

      nested_resource UsersKeys, :association => :api_keys
    end

  end

end

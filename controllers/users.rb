require File.expand_path(File.dirname(__FILE__) + '/users_keys')

module DataCatalog

  class Users < Base
  
    restful_routes do
      name "users"
      model User, :read_only => [
        :api_keys,
        :admin,
        :creator_api_key,
        :created_at,
        :updated_at
      ]
      callback :after_create do
        @document.add_api_key!({ :key_type => "primary" })
      end
      nested_resource UsersKeys
    end

  end

end

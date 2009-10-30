module DataCatalog

  class Users < Base
    include Resource
    
    model User

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :admin
    permission :update => :owner
    permission :delete => :owner

    # == Properties
    
    property :name
    property :email,    :r => :owner
    property :curator,  :r => :owner
    property :admin,    :r => :owner, :w => :nobody

    property :primary_api_key, :r => :owner do |user|
      user.primary_api_key
    end

    property :application_api_keys, :r => :owner do |user|
      user.application_api_keys
    end

    property :valet_api_keys, :r => :owner do |user|
      user.valet_api_keys
    end
    
    # == Callbacks

    callback :after_create do |action, user|
      user.add_api_key!({ :key_type => "primary" })
    end
    
  end
  
  Users.build

end

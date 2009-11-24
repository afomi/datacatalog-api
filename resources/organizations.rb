module DataCatalog

  class Organizations < Base
    include Resource

    model Organization

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties
    
    property :name
    property :acronym
    property :org_type
    property :description
    property :slug
    property :url
    property :user_id,     :w => :nobody
    property :custom,      :w => :admin
    property :raw,         :w => :admin

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end

  Organizations.build

end

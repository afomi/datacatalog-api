module DataCatalog

  class Jurisdictions < Base
    include Resource

    model Jurisdiction

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties
    
    property :name
    property :description
    property :slug
    property :url
    property :user_id,     :w => :nobody

    property :org_count do |source|
      source.organizations.length
    end

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end

  Jurisdictions.build

end

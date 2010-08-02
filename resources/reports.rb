module DataCatalog

  class Reports < Base
    include Resource

    model Report

    # == Permissions

    roles Roles
    permission :list   => :curator
    permission :read   => :curator
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :user_id, :w => :nobody
    property :text
    property :object
    property :status
    property :log

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end

  Reports.build

end

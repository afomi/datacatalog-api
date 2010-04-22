module DataCatalog

  class Imports < Base
    include Resource

    model Import

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :importer_id
    property :status
    property :started_at
    property :finished_at
    property :duration

    # == Callbacks

  end
  
  Imports.build

end

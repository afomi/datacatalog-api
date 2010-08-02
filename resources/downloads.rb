module DataCatalog

  class Downloads < Base
    include Resource

    model Download

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :url
    property :format
    property :preview
    property :size
    property :source_id

    # == Callbacks

  end

  Downloads.build

end

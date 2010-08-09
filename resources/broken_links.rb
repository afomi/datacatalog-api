module DataCatalog

  class BrokenLinks < Base
    include Resource

    model BrokenLink

    # == Permissions

    roles Roles
    permission :list   => :curator
    permission :read   => :curator
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :source_id
    property :organization_id
    property :field
    property :destination_url
    property :status

    # == Callbacks

  end

  BrokenLinks.build

end

module DataCatalog
  
  class SourceGroups < Base
    include Resource
    
    model SourceGroup

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :title
    property :slug
    property :description
    # property :sources

    # == Callbacks

  end
  
  SourceGroups.build

end

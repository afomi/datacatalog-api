module DataCatalog

  class Tags < Base
    include Resource

    model Tag

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner

    # == Properties

    property :text
    property :source_id
    property :user_id

  end
  
  Tags.build

end

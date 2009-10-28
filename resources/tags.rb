module DataCatalog

  class Tags < Base
    include Resource

    model Tag

    # == Permissions

    roles Roles
    permission :read   => :basic
    permission :modify => :curator

    # == Properties

    property :text
    property :source_id
    property :user_id

  end
  
  Tags.build

end

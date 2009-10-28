module DataCatalog
  
  class Documents < Base
    include Resource

    model Document

    # == Permissions

    roles Roles
    permission :read   => :basic
    permission :modify => :curator

    # == Properties
    
    property :text
    property :source_id
    property :user_id
    property :previous_id

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end
  
  Documents.build

end

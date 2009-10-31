module DataCatalog
  
  class Documents < Base
    include Resource

    model Document

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :basic
    permission :update => :basic
    permission :delete => :curator

    # == Properties
    
    property :text
    property :source_id
    property :user_id,     :w => :nobody
    property :previous_id, :w => :nobody
    property :next_id,     :w => :nobody

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end
    
    callback :before_update do |action, document|
      copy = document.create_new_version!
      action.params["previous_id"] = copy.id
      # TODO: this method could be able to be written in one line...
      # document.create_new_version!
      # ...if sinatra_resource paid attention to changes in document. (At
      # present, it only pays attention to params to update the document.)
    end

  end
  
  Documents.build

end

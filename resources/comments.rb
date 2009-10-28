module DataCatalog
  
  class Comments < Base
    include Resource
    
    model Comment

    # == Permissions

    roles Roles
    permission :read   => :basic
    permission :modify => :curator

    # == Properties

    property :text
    property :source_id
    property :user_id
    property :rating_stats, :w => :nobody

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end
  
  Comments.build

end
